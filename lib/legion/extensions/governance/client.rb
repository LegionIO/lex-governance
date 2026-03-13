# frozen_string_literal: true

require 'legion/extensions/governance/helpers/layers'
require 'legion/extensions/governance/helpers/proposal'
require 'legion/extensions/governance/runners/governance'

module Legion
  module Extensions
    module Governance
      class Client
        include Runners::Governance

        def initialize(**)
          @proposal_store = Helpers::Proposal.new
        end

        private

        attr_reader :proposal_store
      end
    end
  end
end
