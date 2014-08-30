require 'spec_helper'

module BrontoIntegration
  describe Contact do
    let(:config) do
      { bronto_api_token: ENV["BRONTO_API_KEY"] }
    end

    it "adds contact on the fly and return id" do
      subject = described_class.new config, {}

      VCR.use_cassette "contacts/add" do
        expect(subject.get_id_by_email "spree@example.com").to be
      end
    end

    it "sets up customer fails" do
      customer = {
        email: "washington@spreecommerce.com",
        billing_address: { phone: "86 9999-6666" },
      }
      subject = described_class.new config, customer: customer

      VCR.use_cassette "contacts/set_up" do
        expect {
          subject.set_up
        }.to raise_error Bronto::ValidationError
      end
    end

    it "sets up customer succeeds" do
      customer = {
        email: "washington@spreecommerce.com"
      }
      subject = described_class.new config, customer: customer

      VCR.use_cassette "contacts/set_up_succeeds" do
        expect(subject.set_up[:id]).to be_present
      end
    end

    it "sets up contact with custom fields" do
      customer = {
        email: "inbloom@nirvana.com",
        fields: {
          lastname: "Nevermind"
        }
      }
      subject = described_class.new config, customer: customer

      VCR.use_cassette "contacts/set_up_fields" do
        expect(subject.set_up[:id]).to be_present
      end
    end

    it "sets up customer update" do
      customer = {
        email: "washington@spreecommerce.com",
        billing_address: { phone: "647 453 2030" }
      }

      subject = described_class.new config, customer: customer

      VCR.use_cassette "contacts/set_up_update" do
        expect(subject.set_up[:id]).to be_present
      end
    end
  end
end
