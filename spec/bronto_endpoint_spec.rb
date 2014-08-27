require 'spec_helper'

describe BrontoEndpoint do
  let(:config) do
  end

  it "rescues bronto validation error" do
    expect(BrontoIntegration::Order).to receive(:new).and_raise(Bronto::ValidationError, "wazzup")

    post "/add_order", {}.to_json, auth
    expect(last_response.status).to eq 500
    expect(json_response[:summary]).to eq "wazzup"
  end
end
