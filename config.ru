require 'bundler/setup'
require 'resque/server'
require File.join(File.dirname(__FILE__), 'config/redis_setup')

run Rack::URLMap.new(
  "/resque" => Resque::Server.new)
