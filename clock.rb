require 'clockwork'
require 'resque'
require File.join(File.dirname(__FILE__), 'config/redis_setup')
require File.join(File.dirname(__FILE__), 'lib/jobs')

include Clockwork

every(5.minutes, 'run ImapJob') do |job|
  Resque.enqueue(ImapJob, ENV['HOST'], ENV['PORT'], ENV['SSL'] == 'true' ? true : false, ENV['USERNAME'], ENV['PASSWORD'])
end
