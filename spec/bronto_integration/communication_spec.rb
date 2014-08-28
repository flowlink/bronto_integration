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
  end
end
