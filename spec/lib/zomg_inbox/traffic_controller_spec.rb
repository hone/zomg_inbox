require_relative "../../spec_helper"
require_relative "../../../lib/zomg_inbox/traffic_controller"

describe TrafficController do
  let(:default_uid) { 57342 }

  describe "#process_log" do
    subject do
      TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/blockbuster_header.txt')))
    end

    it "includes the subject" do
      subject.process_log.should be_include("Your e-coupon is now available!")
    end

    it "includes the destination folder" do
      subject.process_log.should be_include("Blockbuster")
    end

    it "includes the uid" do
      subject.process_log.should match(/^Processing #{default_uid}/)
    end
  end

  describe "#destination" do
    context "has no List ID" do
      subject do
        TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/blockbuster_header.txt')))
      end

      it "returns the to address" do
        subject.destination.should == "Blockbuster"
      end

      context "empty quoted string in to address" do
        subject do
          TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/gog_header.txt')))
        end

        it "returns the to address" do
          subject.destination.should == "Gog"
        end
      end
    end

    context "has a List-Id" do
      context "with with a list name" do
        subject do
          TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/jhu_acm_header.txt')))
        end

        it "has a destination of the List ID" do
          subject.destination.should == "ACM Discussion"
        end
      end

      context "without a list name" do
        context "heroku header" do
          subject do
            TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/heroku_header.txt')))
          end

          it "has a destination of the List ID" do
            subject.destination.should == "Heroku"
          end
        end

        context "ruby header" do
          subject do
            TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/ruby_header.txt')))
          end

          it "has a destination of the List ID" do
            subject.destination.should == "Ruby"
          end
        end
      end

      context "does not match heuristics" do
        subject do
          TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/bad_list_id.txt')))
        end

        it "has no destination" do
          subject.destination.should be_nil
        end
      end

    end

    context "has no To address" do
      subject do
        TrafficController.new(default_uid, File.read(File.join(File.dirname(__FILE__), '../../resources/no_to_address.txt')))
      end

      it "uses the Delivered-To header" do
        subject.destination.should == "Proflowers"
      end
    end
  end
end
