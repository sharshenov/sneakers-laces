# frozen_string_literal: true

module Sneakers
  module Laces
    class Configuration
      attr_accessor :rabbitmq_api_endpoint
      attr_writer   :vhost

      def initialize
        self.rabbitmq_api_endpoint = ENV.fetch('RABBITMQ_API_ENDPOINT') { 'http://guest:guest@localhost:15672/' }
      end

      def vhost
        @vhost || Sneakers::CONFIG.fetch(:vhost)
      end
    end
  end
end
