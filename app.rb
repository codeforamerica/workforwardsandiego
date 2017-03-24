require 'sinatra/base'
require 'sinatra/sequel'
require 'mustache'
require 'dotenv'
require 'pony'
require 'pdf-forms'
require 'tempfile'

module WorkForwardNola
  # WFN app
  class App < Sinatra::Base
    Dotenv.load

    register Sinatra::SequelExtension

    ENV['DATABASE_URL'] ||= "postgres://#{ENV['RDS_USERNAME']}:#{ENV['RDS_PASSWORD']}@#{ENV['RDS_HOSTNAME']}:#{ENV['RDS_PORT']}/#{ENV['RDS_DB_NAME']}"

    configure do
      set :database, ENV['DATABASE_URL']
      enable :logging
    end

    # check for un-run migrations
    if ENV['RACK_ENV'].eql? 'development'
      Sequel.extension :migration
      Sequel::Migrator.check_current(database, 'db/migrations')
    end

    register Mustache::Sinatra
    require './views/layout'

    dir = File.dirname(File.expand_path(__FILE__))

    set :mustache,
        namespace: WorkForwardNola,
        templates: "#{dir}/templates",
        views: "#{dir}/views"

    helpers do
      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end

      def authorized?
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['ADMIN_USER'], ENV['ADMIN_PASSWORD']]
      end
    end

    before do
      response.headers['Cache-Control'] = 'public, max-age=36000'

      # this is convoluted, but I have to require this after setting up the DB
      require './models/trait'
      require './models/career'
      require './models/job_app'
    end

    get '/' do
      @title = 'Work Forward San Diego'
      mustache :index
    end

    post '/careers/update' do
      data = JSON.parse(request.body.read)
      begin
        Trait.bulk_create data['traits']
        Career.bulk_create data['careers']
      rescue Sequel::Error => se
        logger.error "Sequel::Error: #{se}"
        logger.error se.backtrace.join("\n")
        return {
          result: 'error',
          text: "There was an error saving the new data: #{se.to_s.split('DETAIL').first}\n" +
                'Please make sure your data is in the correct format or contact an administrator.'
        }.to_json
      end

      {
        result: 'success',
        text: "Success! #{Trait.count} traits and #{Career.count} careers were saved."
      }.to_json
    end

    get '/assessment' do
      @title = 'Assessment'
      mustache :assessment
    end

    get '/jobsystem' do
      @title = 'Job System'
      mustache :jobsystem
    end

    get '/prepare' do
      @title = 'Prepare'
      mustache :prepare
    end

    post '/pdf' do
      pdftk = PdfForms.new('pdftk')

      pdf_path = 'public/ajcc_membership.pdf'

      form_data = {
          :Email => params[:email],
          :'Last name Family name  surname' => params[:last_name],
          :'First name Given name' => params[:first_name],
          :'Gender identity' => params[:gender],
          :'Primary phone' => params[:phone],
          :'What is your desired job' => params[:desired_job],
          :'Total number of individuals living in your household' => params[:household_size],
          :'Total income you earned within last 6 months' => params[:income]
      }

      form_data[params[:selective_service]] = 'Yes'
      form_data[params[:work_authorization]] = 'Yes'
      form_data[params[:education]] = 'Yes'
      form_data[params[:current_employment_status]] = 'Yes'
      form_data[params[:unemployment_insurance]] = 'Yes'
      form_data[params[:farm_work]] = 'Yes'
      form_data[params[:termination_notice]] = 'Yes'
      form_data[params[:looking_for_work]] = 'Yes'
      form_data[params[:military_caregiver]] = 'Yes'
      form_data[params[:military]] = 'Yes'
      form_data[params[:military_dependent]] = 'Yes'
      form_data[params[:tanf]] = 'Yes'
      form_data[params[:snap]] = 'Yes'
      form_data[params[:general_assistance]] = 'Yes'
      form_data[params[:refugee_cash_assistance]] = 'Yes'
      form_data[params[:current_school]] = 'Yes' if params[:current_school] != 'no'

      if ['employed', 'employed with notice of military separation', 'employed with notice of termination'].include? params[:current_employment_status]
        form_data['Employer'] = params[:employer]
        form_data['Hourly wage'] = params[:wage]
        form_data['Hours worked'] = params[:hours_worked]
      end

      if params[:current_employment_status] == 'not employed'
        form_data['Last employer'] = params[:employer]
        form_data['Hourly wage_2'] = params[:wage]
        form_data['Date last worked'] = params[:date_last_worked]
      end

      form_data['Date'] = Date.today

      job_app = JobApp.new(
          email: params[:email],
          last_name: params[:last_name],
          first_name: params[:first_name],
          phone: params[:phone],
      )

      if params[:services]
        params[:services].each do |val|
          form_data[val] = 'Yes'
        end

        job_app.set(services: params[:services])
      end

      if params[:other_services]
        form_data['Other (Please explain)'] = 'Yes'

        length = params[:other_services].length
        form_data['Other Please explain 1'] = params[:other_services][0..(length/2)]
        form_data['Other Please explain 2'] = params[:other_services][(length/2 + 1)..length]

        job_app.set(other: params[:other_services])
      end

      job_app.save

      filename = "/tmp/#{SecureRandom.urlsafe_base64}.pdf"
      pdftk.fill_form pdf_path, filename, form_data

      send_file filename
    end

    get '/opportunity-center-info' do
      @title = 'Opportunity Center Information'
      mustache :opp_center_info
    end

    post '/careers/email' do
      body = JSON.parse(request.body.read)

      @career_ids = body['career_ids']
      email_body = mustache :careers_email, layout: false

      Pony.mail({
        to: body['recipient'],
        subject: 'Your NOLA Career Results',
        html_body: email_body,
        via: :smtp,
        via_options: {
          address:              ENV['EMAIL_SERVER'],
          port:                 ENV['EMAIL_PORT'],
          enable_starttls_auto: true,
          user_name:            ENV['EMAIL_USER'],
          password:             ENV['EMAIL_PASSWORD'],
          authentication:       :plain, # :plain, :login, :cram_md5, no auth by default
          domain:               ENV['EMAIL_DOMAIN'] # the HELO domain provided by the client to the server
        }
      })

      status 200
      body.to_json # we have to return some JSON so that the callback gets executed in JS
    end

    get '/admin' do
      redirect to('/manage')
    end

    get '/manage' do
      protected!
      @title = 'Manage Content'
      mustache :manage
    end
  end
end
