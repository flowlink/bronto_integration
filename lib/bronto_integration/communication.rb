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
      bronto_client.add_to_list member_payload[:list_name], member_payload[:email]
    end

    def trigger_transactional_email
      bronto_client.add_deliveries build
    end

    def message_id
      @message ||= bronto_client.read_messages email_payload[:message]

      unless @message[:id]
        raise Bronto::ValidationError, "Couldn't find the message template for \"#{template}\""
      end

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
        type: 'transactional',
        fromEmail: email_payload[:from] || config[:bronto_from_email],
        fromName: email_payload[:from_name] || config[:bronto_from_name],
        replyEmail: email_payload[:from] || config[:bronto_from_email],
        recipients: [
          { id: contact_id, type: 'contact' }
        ],
        fields: variables_payload.map do |key, value|
          { name: key.to_s, type: 'html', content: value.to_s }
        end
      }
    end
  end
end
