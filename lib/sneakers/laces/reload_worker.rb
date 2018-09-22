# frozen_string_literal: true

module Sneakers
  module Laces
    class ReloadWorker
      DEFAULT_OPTS = {
        threads:      1,
        queue_options: {
          exclusive:   true,
          auto_delete: true,
          durable:     false
        }
      }.freeze

      class << self
        def configure(worker_tags:)
          routing_keys = worker_tags.map { |tag| routing_key(worker_tag: tag) }

          return if routing_keys.blank?

          include Sneakers::Worker

          # empty queue name makes consumer use dynamic one
          from_queue '', DEFAULT_OPTS.merge(routing_key: routing_keys)
        end

        def routing_key(worker_tag:)
          ['reload', worker_tag].join(':')
        end
      end

      def work(_msg)
        # USR1 signal forces serverengine to gracefully restart child processes
        # https://github.com/treasure-data/serverengine#live-restart
        Process.kill('USR1', Process.pid)
      ensure
        ack!
      end
    end
  end
end
