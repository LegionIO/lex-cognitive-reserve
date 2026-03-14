# frozen_string_literal: true

require_relative 'cognitive_reserve/version'
require_relative 'cognitive_reserve/helpers/constants'
require_relative 'cognitive_reserve/helpers/pathway'
require_relative 'cognitive_reserve/helpers/reserve_engine'
require_relative 'cognitive_reserve/runners/cognitive_reserve'
require_relative 'cognitive_reserve/client'

module Legion
  module Extensions
    module CognitiveReserve
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end
