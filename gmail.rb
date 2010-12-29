require 'net/imap'
require 'bundler/setup'
require 'mail'

@imap = Net::IMAP.new(ENV['HOST'], ENV['PORT'], ENV['SSL'] == 'true' ? true : false)
@imap.login(ENV['USERNAME'], ENV['PASSWORD'])

@imap.select("INBOX")

archive_messages = []
@imap.fetch(1..-1, "(UID BODY.PEEK[HEADER.FIELDS (SUBJECT)] BODY.PEEK[HEADER.FIELDS (TO)])").each do |message|
  mid     = message.seqno
  uid     = message.attr["UID"]
  subject = message.attr["BODY[HEADER.FIELDS (SUBJECT)]"].sub("Subject ", '').chomp.chomp
  folder  = Mail::Address.new(message.attr["BODY[HEADER.FIELDS (TO)]"].sub("To: ", '').chomp.chomp).local.capitalize

  if not @imap.list('OtherInbox/', folder)
    puts "Creating folder OtherInbox/#{folder}"
    @imap.create("OtherInbox/#{folder}")
  end

  puts "Processing #{uid} : #{subject} to #{folder}"
  @imap.copy(mid, "OtherInbox/#{folder}")
  archive_messages << mid
end

# archive email
@imap.store(archive_messages, "+FLAGS", [:Deleted])

@imap.disconnect
