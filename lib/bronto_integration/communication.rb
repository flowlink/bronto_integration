module BrontoIntegration
  class Communication
    attr_reader :config, :bronto_client, :email_payload, :variables_payload,
      :member_payload

    def initialize(config, payload, client = nil)
      @config = config
      @email_payload = payload[:email] || {}
      @variables_payload = email_payload[:variables] || {}
      @member_payload = payload[:member] || {}

      @bronto_client = client || Bronto.new(config[:bronto_api_token])
    end

    def add_to_list
      Contact.new({}, {}, bronto_client).find_or_create member_payload[:email]

      if member_payload[:list_name].is_a? Array
        member_payload[:list_name].each do |list|
          bronto_client.add_to_list list, member_payload[:email]
        end
      else
        bronto_client.add_to_list member_payload[:list_name], member_payload[:email]
      end
    end

    def remove_from_list
      if member_payload[:list_name].is_a? Array
        member_payload[:list_name].each do |list|
          bronto_client.remove_from_list list, member_payload[:email]
        end
      else
        bronto_client.remove_from_list member_payload[:list_name], member_payload[:email]
      end
    end

    def remove_from_all_lists
      lists = bronto_client.read_lists
      lists.map { |l| bronto_client.remove_from_list l[:name], member_payload[:email] }
    end

    def trigger_delivery
      bronto_client.add_deliveries build
    end

    def message_id
      @message ||= bronto_client.read_messages email_payload[:message]
      @message[:id]
    end

    def contact_id
      contact = Contact.new({}, {}, bronto_client)
      contact.get_id_by_email email_payload[:to]
    end

    def build
      {
        start: Time.new.strftime('%FT%T%:z'),
        messageId: message_id,
        type: email_payload[:delivery_type] || 'transactional',
        fromEmail: email_payload[:from] || config[:bronto_from_email],
        fromName: email_payload[:from_name] || config[:bronto_from_name],
        replyEmail: email_payload[:from] || config[:bronto_from_email],
        recipients: [
          { id: contact_id, type: 'contact' }
        ],
        fields: variables_payload.map do |key, value|
          { name: key.to_s, type: email_payload[:message_type] || 'html', content: value.to_s }
        end
      }
    end
  end
end
