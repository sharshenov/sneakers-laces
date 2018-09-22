# frozen_string_literal: true

module Sneakers
  module Laces
    class WorkerManager
      cattr_accessor :workers_by_queues do
        {}
      end

      def initialize(worker_classes = [])
        @worker_classes = worker_classes
        configure_reload_worker
      end

      def workers
        workers = [ReloadWorker]

        worker_classes.map do |worker_class|
          grouped_queues.fetch(worker_class.worker_tag, []).map do |queue|
            workers << workers_by_queues[queue.name] ||= build_worker_class(worker_class, queue)
          end
        end

        workers
      end

      private

      def configure_reload_worker
        ReloadWorker.configure(worker_tags: worker_classes.map(&:worker_tag))
      end

      def worker_classes
        @worker_classes.any? ? @worker_classes : Sneakers::Laces::Worker::Classes
      end

      def build_worker_class(worker_class, queue)
        Class.new(worker_class) do
          include Sneakers::Worker

          from_queue  queue.fetch(:name),
                      worker_class.worker_opts.deep_merge(arguments: queue.fetch(:arguments))
        end
      end

      def grouped_queues
        @grouped_queues ||= QueueManager.new.grouped_queues
      end
    end
  end
end
