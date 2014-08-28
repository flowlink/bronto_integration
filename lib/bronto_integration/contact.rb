module BrontoIntegration
  class Contact
    attr_reader :bronto_client, :customer, :billing_address

    def initialize(config, payload, client = nil)
      @bronto_client = client || Bronto.new(config[:bronto_api_token])

      @customer = payload[:customer] || {}
      @billing_address = customer[:billing_address] || {}
    end

    def get_id_by_email(email)
      if contact_id = bronto_client.read_contacts(email)
        contact_id
      else
        result = bronto_client.add_or_update_contacts({ email: email })
        result[:id]
      end
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
          :fieldId => bronto_client.get_field_id(key.to_s),
          :content => value.to_s
        }
      end
    end
  end
end
