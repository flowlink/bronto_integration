module BrontoIntegration
  class Order
    attr_reader :bronto_client, :order_payload

    def initialize(config, payload)
      @bronto_client = Bronto.new config[:bronto_api_token]
      @order_payload = payload[:order]
    end

    def build
      {
        :id => order_payload[:id],
        :email => order_payload[:email],
        :contactId => contact_id,
        :products => line_items,
        :orderDate => order_payload[:placed_on]
      }
    end

    def create_or_update
      bronto_client.add_or_update_orders build
    end

    def line_items
      order_payload[:line_items].inject([]) do |items, item|
        items << {
          :id => item[:product_id],
          :sku => item[:sku],
          :name => item[:name],
          :quantity => item[:quantity],
          :price => item[:price]
        }

        items
      end
    end

    def contact_id
      contact = Contact.new({}, {}, bronto_client)
      contact.get_id_by_email order_payload[:email]
    end
  end
end
