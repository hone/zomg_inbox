require 'bundler/setup'
require 'resque/server'
require File.join(File.dirname(__FILE__), 'config/redis_setup')


# Set the AUTH env variable to your basic auth password to protect Resque.
AUTH_PASSWORD = ENV['AUTH']
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

run Rack::URLMap.new(
  "/resque" => Resque::Server.new)
