require 'spec_helper'

module BrontoIntegration
  describe Communication do
    let(:config) do
      {
        bronto_api_token: ENV["BRONTO_API_KEY"],
        bronto_from_email: "dontreply@spreecommerce.com",
        bronto_from_name: "Spree Commerce"
      }
    end

    it "triggers a transactional email" do
      payload = {
        email: {
          to: "washington@spreecommerce.com",
          message: "Wombat First Message",
          variables: {
            username: "Washington L"
          }
        }
      }

      subject = described_class.new config, payload

      VCR.use_cassette "communication/send_email" do
        subject.trigger_transactional_email
      end
    end

    it "adds contact to given list" do
      payload = {
        member: {
          email: "washington@spreecommerce.com",
          list_name: "spree"
        }
      }

      subject = described_class.new config, payload

      VCR.use_cassette "communication/add_to_spree_list" do
        subject.add_to_list
      end
    end

    it "adds contact to more than one list" do
      payload = {
        member: {
          email: "spree@wombat.co",
          list_name: ["spree", "wombat"]
        }
      }

      subject = described_class.new config, payload

      VCR.use_cassette "communication/add_multiple_list" do
        subject.add_to_list
      end
    end

    it "removes a contact from multiple lists" do
      payload = {
        member: {
          email: "spree@wombat.co",
          list_name: ["wombat", "spree"]
        }
      }

      subject = described_class.new config, payload

      VCR.use_cassette "communication/remove_from_multiple_list" do
        subject.remove_from_list
      end
    end

    it "removes a contact from given list" do
      payload = {
        member: {
          email: "wombat@spreecommerce.com",
          list_name: "wombat"
        }
      }

      subject = described_class.new config, payload

      VCR.use_cassette "communication/remove_from_list" do
        subject.remove_from_list
      end
    end

    it "removes a contact from all lists" do
      payload = {
        member: {
          email: "washington@spreecommerce.com"
        }
      }

      subject = described_class.new config, payload

      VCR.use_cassette "communication/remove_from_all_lists" do
        subject.remove_from_all_lists
      end
    end
  end
end
