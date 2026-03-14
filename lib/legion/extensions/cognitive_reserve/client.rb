# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveReserve
      class Client
        include Runners::CognitiveReserve

        def initialize(engine: nil)
          @engine = engine
        end
      end
    end
  end
end
