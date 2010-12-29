require 'resque'

redis_url    = ENV["REDISTOGO_URL"] ||= "redis://localhost:6379/"
uri          = URI.parse(redis_url)
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
