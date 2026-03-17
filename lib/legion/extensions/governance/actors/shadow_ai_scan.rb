# frozen_string_literal: true

module Legion
  module Extensions
    module Governance
      module Actors
        class ShadowAiScan < Legion::Extensions::Actors::Every
          def runner_class = Runners::ShadowAi
          def runner_function = 'full_scan'
          def time = 86_400
        end
      end
    end
  end
end
