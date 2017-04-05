require 'sinatra/base'
require 'sinatra/sequel'
require 'dotenv'
require './services/membership_application_service'
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

      send_file MembershipApplicationService.new(job_app, params[:services]).get_filled_form
    end
  end
end
