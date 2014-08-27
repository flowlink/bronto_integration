require 'spec_helper'

module BrontoIntegration
  describe Order do
    let(:order) do
      JSON.parse(IO.read("#{File.dirname(__FILE__)}/../support/samples/order.json")).with_indifferent_access
    end

    let(:config) do
      { bronto_api_token: ENV["BRONTO_API_KEY"] }
    end

    subject { described_class.new config, { order: order } }

    it "adds order" do
      VCR.use_cassette "orders/add" do
        subject.create_or_update
      end
    end
  end
end
