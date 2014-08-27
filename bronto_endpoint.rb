require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/bronto_integration')

class BrontoEndpoint < EndpointBase::Sinatra::Base
  endpoint_key ENV['ENDPOINT_KEY']

  Honeybadger.configure do |config|
    config.api_key = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end if ENV['HONEYBADGER_KEY'].present?

  error Bronto::ValidationError do
    result 500, env['sinatra.error'].message
  end

  ["/add_order", "/update_order"].each do |path|
    post path do
      BrontoIntegration::Order.new(@config, @payload).create_or_update
      result 200, "Order info sent to Bronto"
    end
  end

  ["/add_customer", "/update_customer"].each do |path|
    post path do
      BrontoIntegration::Contact.new(@config, @payload).set_up
      result 200, "Contact info sent to Bronto"
    end
  end
end
