require 'spec_helper'

describe BrontoEndpoint do
  let(:order) do
    JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/samples/order.json")).with_indifferent_access
  end

  let(:config) do
    { bronto_api_token: ENV["BRONTO_API_KEY"] }
  end

  it "responds to health check" do
    get "/"
    expect(last_response.status).to eq 200
  end

  it "rescues bronto validation error" do
    expect(BrontoIntegration::Order).to receive(:new).and_raise(Bronto::ValidationError, "wazzup")

    post "/add_order", {}.to_json, auth
    expect(last_response.status).to eq 500
    expect(json_response[:summary]).to eq "wazzup"
  end

  it "adds order" do
    VCR.use_cassette "orders/add" do
      post "/add_order", { order: order, parameters: config }.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  it "adds contact" do
    customer = {
      email: "washington@spreecommerce.com",
      billing_address: { phone: "86 9999-6666" },
    }
    
    VCR.use_cassette "contacts/set_up_update" do
      post "/update_customer", { customer: customer, parameters: config }.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  it "removes from list" do
    member = { email: "wombat@spreecommerce.com" }
    
    VCR.use_cassette "communication/remove_from_list" do
      post "/remove_from_list", { member: member, parameters: config }.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  it "removes from all lists" do
    member = { email: "wombat@spreecommerce.com" }
    
    VCR.use_cassette "communication/remove_from_all_lists" do
      post "/remove_from_all_lists", { member: member, parameters: config }.to_json, auth
      expect(last_response.status).to eq 200
    end
  end
end
