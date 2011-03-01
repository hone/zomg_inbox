require 'bundler/setup'
require 'resque/tasks'

task "resque:setup" do
  require_relative 'config/redis_setup'
  require_relative 'lib/jobs'
  ENV['QUEUE'] = '*'
end

if ENV['RACK_ENV'] != 'production'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
end
