require 'mail'
require_relative '../mail/parsers/rfc2822'

# figures out what folder the mail should go to
class TrafficController
  def initialize(uid, headers)
    @uid     = uid
    @headers = Mail::Header.new(headers)
  end

  def process_log
    "Processing #{@uid} : #{@headers['Subject']} moved to #{destination}"
  end

  def destination
    # check for mailing list
    if @headers['List-Id']
      match_data = /(?<list_name>[\w\d\s_-]*?) ?<(?<list_id>[\w\d.@-]+)>/.match(@headers['List-Id'].value.to_s)
      if match_data
        if match_data[:list_name].empty?
          match_data[:list_id].split('@').first.split('.').first.capitalize
        else
          match_data[:list_name]
        end
      else
        puts "ERROR: Could not parse mailing list: #{@headers['List-Id'].value.to_s}"
        return nil
      end
    # default to To address if there isn't something better
    else
      to_address = @headers["To"] || @headers["Delivered-To"]
      if to_address
        Mail::Address.new(to_address.value.to_s).local.capitalize
      else
        puts "ERROR: No To address for: #{@headers['Subject']}"
      end
    end
  end
end
