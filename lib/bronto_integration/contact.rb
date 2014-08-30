module BrontoIntegration
  class Contact
    attr_reader :bronto_client, :customer, :billing_address

    def initialize(config, payload, client = nil)
      @bronto_client = client || Bronto.new(config[:bronto_api_token])

      @customer = payload[:customer] || {}
      @billing_address = customer[:billing_address] || {}
    end

    def get_id_by_email(email)
      unless contact = bronto_client.read_contacts(email)
        contact = bronto_client.add_or_update_contacts({ email: email })
      end
      
      contact[:id]
    end

    alias :find_or_create :get_id_by_email

    def set_up
      bronto_client.add_or_update_contacts build
    end

    def build
      {
        :email => customer[:email],
        :mobileNumber => billing_address[:phone],
        :fields => fields
      }
    end

    def fields
      fields = (customer[:fields] || []).map do |key, value|
        {
          :fieldId => get_field_id(key.to_s),
          :content => value.to_s
        }
      end
    end

    def get_field_id(name)
      result = bronto_client.read_fields(key.to_s)
      result[:id] if result.is_a? Hash
    end
  end
end
