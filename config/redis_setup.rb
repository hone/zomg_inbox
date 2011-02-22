require 'resque'

redis_url    = ENV["REDISTOGO_URL"] ||= "redis://localhost:6379/"
uri          = URI.parse(redis_url)

CONFIG ||= {}
CONFIG[:redis] = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis = CONFIG[:redis]
