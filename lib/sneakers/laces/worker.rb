# frozen_string_literal: true

module Sneakers
  module Laces
    module Worker
      Classes = []

      def self.included(base)
        base.extend ClassMethods
        Classes << base if base.is_a? Class
      end

      module ClassMethods
        attr_reader :worker_opts
        attr_reader :worker_tag

        def from_tag(tag, opts = { routing_key: [] })
          @worker_tag   = tag.to_s
          @worker_opts  = opts
        end
      end
    end
  end
end
