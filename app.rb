require 'sinatra/base'
require 'sinatra/sequel'
require 'mustache'
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

    get '/prepare' do
      @title = 'Prepare'
      mustache :prepare
    end

    post '/pdf' do
      job_app = JobAppBuilder.new(params).build

      send_file MembershipApplicationService.new(job_app, params[:services]).get_filled_form
    end

    get '/opportunity-center-info' do
      @title = 'Opportunity Center Information'
      mustache :opp_center_info
    end
  end
end
