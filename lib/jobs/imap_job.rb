require 'net/imap'
require 'mail'
require 'gmail_xoauth'
require_relative '../zomg_inbox/traffic_controller'

class ImapJob
  @queue = :imap

  def self.perform(host, port, ssl, user)
    imap = Net::IMAP.new(host, port, ssl)
    imap.authenticate('XOAUTH', user['email'],
      consumer_key: ENV['CONSUMER_KEY'],
      consumer_secret: ENV['CONSUMER_SECRET'],
      token: user['token'],
      token_secret: user['token_secret'])

    imap.select("INBOX")

    archive_messages = []
    messages = imap.fetch(1..-1, "(UID BODY.PEEK[HEADER])")
    if messages
      messages.each do |message|
        mid     = message.seqno
        uid     = message.attr["UID"]
        headers = message.attr["BODY[HEADER]"]
        tc      = TrafficController.new(uid, headers)
        folder  = tc.destination

        if folder
          prefix = user['prefix'].to_s.empty? ? '' : "#{user['prefix']}/"
          path = prefix + folder
          if not imap.list(prefix, folder)
            puts "Creating folder #{path}"
            imap.create(path)
          end

          puts tc.process_log
          imap.copy(mid, path)
          archive_messages << mid
        end
      end
    end

    # archive email
    imap.store(archive_messages, "+FLAGS", [:Deleted]) if archive_messages.any?

    imap.disconnect
  end
end
