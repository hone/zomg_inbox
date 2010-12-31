require 'bundler/setup'
require 'resque/tasks'

task "resque:setup" do
  require File.join(File.dirname(__FILE__), 'config/redis_setup')
  require File.join(File.dirname(__FILE__), 'lib/jobs')
  ENV['QUEUE'] = '*'
end

if ENV['RACK_ENV'] != 'production'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
end
