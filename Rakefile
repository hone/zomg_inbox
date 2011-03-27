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

task :move_email do
  require 'net/imap'
  require 'gmail_xoauth'
  require_relative 'config/couchdb_setup'
  db = CONFIG[:couchdb]
  user = db.view('user/emails', key: 'hone@hone.oib.com')['rows'].first['value']
  imap = Net::IMAP.new(ENV['HOST'], ENV['IMAP_PORT'], true)
  imap.authenticate('XOAUTH', user['email'],
                    consumer_key: ENV['CONSUMER_KEY'],
                    consumer_secret: ENV['CONSUMER_SECRET'],
                    token: user['token'],
                    token_secret: user['token_secret'])
  puts "Connected to IMAP"

  imap.list("OtherInbox/", "%").each do |mailbox_list|
    folder = mailbox_list.name.split("/").last
    path = "ZOMG/#{folder}"

    puts "renaming #{mailbox_list.name} to #{path}"
    imap.rename(mailbox_list.name, path)
  end
end

task :copy_otherinbox_mail do
  require 'net/imap'
  require 'gmail_xoauth'
  puts "connecting to OIB"
  oib = Net::IMAP.new('imap.otherinbox.com', {port: 993, ssl: true })
  oib.login('hone', 'aajife')
  puts "Connected to OIB"

  puts "List: #{oib.lsub("OtherInbox/", "*")}"

  # imap.list("OtherInbox/", "%").each do |mailbox_list|
  #   folder = mailbox_list.name.split("/").last
  #   path = "ZOMG/#{folder}"

  #   puts "renaming #{mailbox_list.name} to #{path}"
  #   imap.rename(mailbox_list.name, path)
  # end
end
