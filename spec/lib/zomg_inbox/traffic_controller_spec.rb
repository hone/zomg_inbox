require File.join(File.dirname(__FILE__), "../../spec_helper")
require File.join(File.dirname(__FILE__), "../../../lib/zomg_inbox/traffic_controller")

describe TrafficController do
  describe "#destination" do
    context "has no List ID" do
      subject { TrafficController.new('BODY[HEADER.FIELDS (TO)]' => 'To: Fred Flinstone <foo@blarg.oib.com>') }
      it "returns the to to address" do
        subject.destination.should == "Foo"
      end
    end
  end
end
