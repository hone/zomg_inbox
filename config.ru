require 'bundler/setup'
require 'warden'
require 'warden-googleapps'
require 'resque/server'
require File.join(File.dirname(__FILE__), 'config/redis_setup')
require File.join(File.dirname(__FILE__), 'web')

use Rack::CommonLogger

map "/resque" do
  if ENV['GOOGLE_APPS_DOMAIN']
    require File.join(File.dirname(__FILE__), 'lib/resque/server')
    use Rack::Session::Cookie
    use Warden::Manager do |manager|
      manager.default_strategies :google_apps

      manager[:google_apps_domain]   = ENV['GOOGLE_APPS_DOMAIN']
    end
  elsif ENV['AUTH']
    # Set the AUTH env variable to your basic auth password to protect Resque.
    AUTH_PASSWORD = ENV['AUTH']
    if AUTH_PASSWORD
      Resque::Server.use Rack::Auth::Basic do |username, password|
        password == AUTH_PASSWORD
      end
    end
  end

  run Resque::Server.new
end

map "/" do
  run ZomgInboxWeb
end
