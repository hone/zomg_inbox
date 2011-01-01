require 'mail'

# figures out what folder the mail should go to
class TrafficController
  def initialize(headers)
    @headers = Mail::Header.new(headers)
  end

  def destination
    Mail::Address.new(@headers["To"].value).local.capitalize
  end
end
