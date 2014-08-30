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
      result 200, "Order #{@payload[:order][:id]} sent to Bronto"
    end
  end

  ["/add_customer", "/update_customer"].each do |path|
    post path do
      BrontoIntegration::Contact.new(@config, @payload).set_up
      result 200, "Contact #{@payload[:customer][:email]} sent to Bronto"
    end
  end

  post "/send_email" do
    BrontoIntegration::Communication.new(@config, @payload).trigger_transactional_email
    result 200, "Email added to deliveries"
  end

  post "/add_to_list" do
    BrontoIntegration::Communication.new(@config, @payload).add_to_list
    result 200, "#{@payload[:member][:email]} added to list #{@payload[:member][:list_name]}"
  end

  post "/remove_from_list" do
    BrontoIntegration::Communication.new(@config, @payload).remove_from_list
    result 200, "Contact #{@payload[:member][:email]} successfully removed from list #{@payload[:member][:list_name]}"
  end

  post "/remove_from_all_lists" do
    BrontoIntegration::Communication.new(@config, @payload).remove_from_all_lists
    result 200, "Contact #{@payload[:member][:email]} successfully removed from all lists"
  end
end
