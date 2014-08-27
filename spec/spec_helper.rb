require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'lib/bronto_integration')
require File.join(File.dirname(__FILE__), '..', 'bronto_endpoint')

Dir["./spec/support/**/*.rb"].each { |f| require f }

require 'spree/testing_support/controllers'

Sinatra::Base.environment = 'test'

ENV['BRONTO_API_KEY'] ||= 'apikey'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data("BRONTO_API_KEY") { ENV["BRONTO_API_KEY"] }
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers
end
