require 'clockwork'
require 'resque'
require File.join(File.dirname(__FILE__), 'config/redis_setup')
require File.join(File.dirname(__FILE__), 'config/couchdb_setup')
require File.join(File.dirname(__FILE__), 'lib/jobs')

include Clockwork

db = CONFIG[:couchdb]

every(5.minutes, 'run ImapJob') do |job|
  rows = db.view("user/emails")["rows"]
  if rows.any?
    rows.each do |row|
      doc = db.get(row['id'])
      Resque.enqueue(ImapJob, ENV['HOST'], ENV['IMAP_PORT'], ENV['SSL'] == 'true' ? true : false, doc['email'], doc['token'], doc['token_secret'])
    end
  end
end
