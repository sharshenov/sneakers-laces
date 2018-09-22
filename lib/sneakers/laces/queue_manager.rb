# frozen_string_literal: true

module Sneakers
  module Laces
    class QueueManager
      WORKER_TAG_ARGUMENT = 'x-worker-tag'

      def declare_queue(name:, worker_tag:, routing_key: nil, binding_arguments: [], params: {}, reload: true)
        api_client.declare_queue  vhost,
                                  name,
                                  params_with_worker_tag(worker_tag, params)

        api_client.bind_queue(vhost, name, exchange, (routing_key || name), binding_arguments)

        reload_worker(worker_tag) if reload
      end

      def grouped_queues
        filtered_queues.group_by { |q| q.arguments[WORKER_TAG_ARGUMENT] }
      end

      def list_queues
        api_client.list_queues(vhost)
      rescue Faraday::ResourceNotFound
        Sneakers.logger.error("Vhost '#{vhost}' does not exist.")
        []
      end

      def delete_queue(name:, worker_tag:, reload: true)
        api_client.delete_queue vhost, name

        reload_worker(worker_tag) if reload
      rescue Faraday::ResourceNotFound
        false
      end

      def queue_info(name:)
        api_client.queue_info vhost, name
      end

      private

      def reload_worker(worker_tag)
        Sneakers::Laces.reload(worker_tag: worker_tag)
      end

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

      def exchange
        Sneakers::CONFIG.fetch(:exchange)
      end
    end
  end
end
