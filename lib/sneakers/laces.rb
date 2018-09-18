# frozen_string_literal: true

require 'rabbitmq/http/client'
require 'active_support'
require 'active_support/core_ext'

require 'sneakers/laces/version'
require 'sneakers/laces/configuration'
require 'sneakers/laces/queue_manager'
require 'sneakers/laces/consumer_manager'
require 'sneakers/laces/worker'
require 'sneakers'

module Sneakers
  module Laces
    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield(config)
        @api_client = nil # ensure api client uses actual endpoint
      end

      def api_client
        @api_client ||= RabbitMQ::HTTP::Client.new(config.rabbitmq_api_endpoint)
      end
    end
  end
end
