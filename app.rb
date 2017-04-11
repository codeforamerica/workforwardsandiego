require 'sinatra/base'
require 'sinatra/sequel'
require 'dotenv'
require './services/preparation_materials_service'
require './services/job_app_builder'

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

    dir = File.dirname(File.expand_path(__FILE__))

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
      require './models/job_app'
    end

    get '/' do
      @title = 'Work Forward San Diego'
      erb :index
    end

    get '/prepare' do
      @title = 'Prepare'
      erb :prepare
    end

    post '/job_apps/create' do
      job_app = JobAppBuilder.new(params).build

      redirect to("caljobs/#{job_app.id}")
    end

    get '/caljobs/:id' do
      @title = 'Create a CalJobs profile'
      @job_app_id = params['id']
      erb :caljobs
    end

    get '/ready/:id' do
      @title = 'All Set!'
      @job_app_id = params['id']
      erb :ready
    end

    get '/pdf/:id' do
      job_app = JobApp[params[:id]]

      send_file PreparationMaterialsService.new(job_app, params[:services], request.host_with_port).run
    end

    def public_assistance(job_app)
      [].tap do |public_assistance|
        public_assistance.push('TANF') if job_app.tanf
        public_assistance.push('SNAP') if job_app.snap
        public_assistance.push('GA') if job_app.general_assistance
        public_assistance.push('RCA') if job_app.refugee_cash_assistance
      end
    end

    get '/intake/:id' do
      @job_app = JobApp[params[:id]]
      @title = 'Intake Form'
      @public_assistance = public_assistance(@job_app)
      @barriers = [
          'Housing/Homeless',
          'Criminal Records',
          'Transportation',
          'Health Issues',
          'Disability',
          'ESL',
          'Financial Difficulties',
          'Poor Work History',
          'Daycare Issues',
          'Computer Skills',
          'Other ________________________'
      ]

      erb :intake, layout: false
    end
  end
end
