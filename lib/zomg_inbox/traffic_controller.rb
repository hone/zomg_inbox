require 'mail'

# figures out what folder the mail should go to
class TrafficController
  def initialize(attr)
    @attr = attr
  end

  def destination
    Mail::Address.new(@attr["BODY[HEADER.FIELDS (TO)]"].sub("To: ", '').chomp.chomp).local.capitalize
  end
end
