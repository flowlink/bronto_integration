require 'savon'

class Bronto
  class ValidationError < StandardError; end

  attr_reader :client, :token

  # NOTE Try building a response object?

  def initialize(token)
    @token = token
    @client = Savon.client(
      ssl_verify_mode: :none,
      wsdl: 'https://api.bronto.com/v4?wsdl',
      log_level: :debug,
      log: true,
      namespace_identifier: :v4,
      env_namespace: :soapenv
    )
  end

  def add_or_update_orders(data)
    client.call(
      :add_or_update_orders,
      soap_header: soup_header,
      message: { :orders => data }
    )
  end

  # Ref: http://dev.bronto.com/api/v4/functions/add/addorupdatecontacts
  #
  # Successful example:
  #
  #   {:id=>"ac41a110-bd21-4bf6-b061-625dfa428a27", :is_new=>true, :is_error=>false, :error_code=>"0"}
  #
  # Error example:
  #   
  #   {:is_error=>true, :error_code=>"319", :error_string=>"Invalid mobile number: 86 9999-6666"}
  #
  def add_or_update_contacts(data)
    response = client.call(
      :add_or_update_contacts,
      soap_header: soup_header,
      message: { :contacts => data }
    )

    result = get_results response.body[:add_or_update_contacts_response]

    if result[:is_error]
      raise ValidationError, "(Error Code: #{result[:error_code]}) #{result[:error_string]}"
    else
      result
    end
  end

  def read_contacts(email)
    response = client.call(
      :read_contacts,
      soap_header: soup_header,
      message: {
        :filter => [:email => { :operator => 'EqualTo', :value => email }],
        :includeLists => false,
        :fields => 'id',
        :pageNumber => 1,
        :includeSMSKeywords => false,
        :includeGeoIPData => false,
        :includeTechnologyData => false,
        :includeRFMData => false
      }
    )

    if result = response.body[:read_contacts_response][:return]
      result[:id]
    end
  end

  def get_field_id(name)
    response = client.call(
      :read_fields,
      soap_header: soup_header,
      message: {
        filter: {
          :name => {
            :operator => 'EqualTo',
            :value => name }
        },
      }
    )

    value = response.body[:read_fields_response][:return]
    value[:id] if value.is_a? Hash
  end

  private
    def session_id
      return @session_id if @session_id

       login_response = @client.call(:login, message: { :api_token => token })
       @session_id = login_response.body[:login_response][:return]
    end

    def soup_header
      { 'v4:sessionHeader' => { :session_id => session_id } }
    end

    def get_results(body)
      body[:return][:results]
    end
end
