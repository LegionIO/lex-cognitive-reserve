# frozen_string_literal: true

require 'legion/extensions/cognitive_reserve'

unless defined?(Legion::Logging)
  module Legion
    module Logging
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def log; end
      end

      def log; end
    end
  end
end
