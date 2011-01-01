require File.join(File.dirname(__FILE__), "../../spec_helper")
require File.join(File.dirname(__FILE__), "../../../lib/zomg_inbox/traffic_controller")

describe TrafficController do
  describe "#destination" do
    context "has no List ID" do
      subject do
        TrafficController.new(File.read(File.join(File.dirname(__FILE__), '../../resources/blockbuster_header.txt')))
      end

      it "returns the to to address" do
        subject.destination.should == "Blockbuster"
      end
    end
      end
    end
  end
end
