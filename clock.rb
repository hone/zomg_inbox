require 'clockwork'
require 'resque'
require_relative 'config/redis_setup'
require_relative 'config/couchdb_setup'
require_relative 'lib/jobs'

include Clockwork

db = CONFIG[:couchdb]

every(5.minutes, 'run ImapJob') do |job|
  db.view("user/emails")["rows"].each do |row|
    doc = row['value']
    puts "Processing account #{doc['email']}"
    Resque.enqueue(ImapJob, ENV['HOST'], ENV['IMAP_PORT'], ENV['SSL'] == 'true', doc)
  end
end
