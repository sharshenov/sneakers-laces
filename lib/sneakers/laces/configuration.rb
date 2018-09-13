# frozen_string_literal: true

module Sneakers
  module Laces
    class Configuration
      attr_writer   :rabbitmq_api_endpoint,
                    :vhost,
                    :consumers_mapping

      def vhost
        @vhost || Sneakers::CONFIG.fetch(:vhost)
      end

      def rabbitmq_api_endpoint
        @rabbitmq_api_endpoint || ENV.fetch('RABBITMQ_API_ENDPOINT') { 'http://guest:guest@localhost:15672/' }
      end

      def consumers_mapping
        @consumers_mapping || {}
      end
    end
  end
end
