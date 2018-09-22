# frozen_string_literal: true

require 'sneakers/runner'

module Sneakers
  module Laces
    class Runner
      def run
        Sneakers::Runner.new(runner_config).run
      end

      def runner_config
        -> { WorkerManager.new.workers }
      end
    end
  end
end
