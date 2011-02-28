require 'clockwork'
require 'resque'
require File.join(File.dirname(__FILE__), 'config/redis_setup')
require File.join(File.dirname(__FILE__), 'config/couchdb_setup')
require File.join(File.dirname(__FILE__), 'lib/jobs')

include Clockwork

db = CONFIG[:couchdb]

every(5.minutes, 'run ImapJob') do |job|
  db.view("user/emails")["rows"].each do |row|
    doc = row['value']
    puts "Processing account #{doc['email']}"
    Resque.enqueue(ImapJob, ENV['HOST'], ENV['IMAP_PORT'], ENV['SSL'] == 'true', doc)
  end
end
