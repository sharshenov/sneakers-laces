# frozen_string_literal: true

module Sneakers
  module Laces
    class ConsumerManager
      cattr_accessor :consumers_by_queues do
        {}
      end

      def consumers
        consumers_mapping.map do |worker_tag, worker_module|
          grouped_queues.fetch(worker_tag.to_s, []).map do |queue|
            consumers_by_queues[queue.name] ||= build_worker_class(worker_module, queue)
          end
        end

        consumers_by_queues.values
      end

      private

      def consumers_mapping
        Sneakers::Laces.config.consumers_mapping
      end

      def build_worker_class(worker_module, queue)
        Class.new do
          include Sneakers::Worker
          include worker_module

          from_queue  queue.fetch(:name),
                      arguments: queue.fetch(:arguments)
        end
      end

      def grouped_queues
        @grouped_queues ||= QueueManager.new.grouped_queues
      end
    end
  end
end
