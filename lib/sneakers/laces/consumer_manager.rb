# frozen_string_literal: true

module Sneakers
  module Laces
    class ConsumerManager
      cattr_accessor :consumers_by_queues do
        {}
      end

      def initialize(worker_classes = [])
        @worker_classes = worker_classes
      end

      def consumers
        consumers = []

        worker_classes.map do |worker_class|
          grouped_queues.fetch(worker_class.consumer_tag, []).map do |queue|
            consumers << consumers_by_queues[queue.name] ||= build_worker_class(worker_class, queue)
          end
        end

        consumers
      end

      private

      def worker_classes
        @worker_classes.any? ? @worker_classes : Sneakers::Laces::Worker::Classes
      end

      def build_worker_class(worker_class, queue)
        Class.new(worker_class) do
          include Sneakers::Worker

          from_queue  queue.fetch(:name),
                      worker_class.consumer_opts.deep_merge(arguments: queue.fetch(:arguments))
        end
      end

      def grouped_queues
        @grouped_queues ||= QueueManager.new.grouped_queues
      end
    end
  end
end
