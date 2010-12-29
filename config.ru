require 'bundler/setup'
require 'resque/server'

run Rack::URLMap.new(
  "/resque" => Resque::Server.new)
