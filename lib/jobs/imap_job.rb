require 'net/imap'
require 'mail'
require 'gmail_xoauth'
require File.join(File.dirname(__FILE__), '../zomg_inbox/traffic_controller')

class ImapJob
  @queue = :imap

  def self.perform(host, port, ssl, username, token, token_secret)
    imap = Net::IMAP.new(host, port, ssl)
    imap.authenticate('XOAUTH', username,
      consumer_key: ENV['CONSUMER_KEY'],
      consumer_secret: ENV['CONSUMER_SECRET'],
      token: token,
      token_secret: token_secret)

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
          if not imap.list('OtherInbox/', folder)
            puts "Creating folder OtherInbox/#{folder}"
            imap.create("OtherInbox/#{folder}")
          end

          puts tc.process_log
          imap.copy(mid, "OtherInbox/#{folder}")
          archive_messages << mid
        end
      end
    end

    # archive email
    imap.store(archive_messages, "+FLAGS", [:Deleted]) if archive_messages.any?

    imap.disconnect
  end
end
