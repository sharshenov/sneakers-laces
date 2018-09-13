# frozen_string_literal: true

module Sneakers
  module Laces
    class QueueManager
      WORKER_TAG_ARGUMENT = 'x-worker-tag'

      def declare_queue(name:, worker_tag:, params: {})
        api_client.declare_queue  vhost,
                                  name,
                                  params_with_worker_tag(worker_tag, params)
      end

      def grouped_queues
        filtered_queues.group_by { |q| q.arguments[WORKER_TAG_ARGUMENT] }
      end

      def list_queues
        api_client.list_queues(vhost)
      end

      def delete_queue(name:)
        api_client.delete_queue vhost, name
      rescue Faraday::ResourceNotFound
        false
      end

      def queue_info(name:)
        api_client.queue_info vhost, name
      end

      private

      def filtered_queues
        list_queues.select { |q| q.arguments[WORKER_TAG_ARGUMENT].present? }
      end

      def params_with_worker_tag(worker_tag, params = {})
        Sneakers::CONFIG.fetch(:queue_options).merge(params.deep_symbolize_keys).tap do |p|
          p[:arguments][WORKER_TAG_ARGUMENT] = worker_tag
        end
      end

      def api_client
        Sneakers::Laces.api_client
      end

      def vhost
        Sneakers::Laces.config.vhost
      end
    end
  end
end
