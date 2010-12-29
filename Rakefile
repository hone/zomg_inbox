require 'bundler/setup'
require 'resque/tasks'

task "resque:setup" do
  require File.join(File.dirname(__FILE__), 'config/redis_setup')
  require File.join(File.dirname(__FILE__), 'lib/jobs')
  ENV['QUEUE'] = '*'
end
