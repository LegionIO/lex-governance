# frozen_string_literal: true

module Legion
  module Extensions
    module Governance
      module Runners
        module Governance
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def create_proposal(category:, description:, proposer:, council_size: nil, **)
            return { error: :invalid_category, valid: Helpers::Layers::PROPOSAL_CATEGORIES } unless Helpers::Layers.valid_category?(category)

            size = council_size || Helpers::Layers::MIN_COUNCIL_SIZE
            id = proposal_store.create(category: category, description: description,
                                       proposer: proposer, council_size: size)
            { proposal_id: id, category: category, status: :open }
          end

          def vote_on_proposal(proposal_id:, voter:, approve:, **)
            result = proposal_store.vote(proposal_id, voter: voter, approve: approve)
            case result
            when nil then { error: :not_found_or_closed }
            when :already_voted then { error: :already_voted }
            else { voted: true, resolution: result }
            end
          end

          def get_proposal(proposal_id:, **)
            prop = proposal_store.get(proposal_id)
            prop ? { found: true, proposal: prop } : { found: false }
          end

          def open_proposals(**)
            props = proposal_store.open_proposals
            { proposals: props, count: props.size }
          end

          def validate_action(layer:, action:, context: {}, **)
            return { error: :invalid_layer } unless Helpers::Layers.valid_layer?(layer)

            case layer
            when :agent_validation
              { allowed: true, layer: layer, reason: :self_validated }
            when :anomaly_detection
              { allowed: true, layer: layer, reason: :no_anomaly }
            when :human_deliberation
              { allowed: false, layer: layer, reason: :requires_human_approval }
            when :transparency
              { allowed: true, layer: layer, reason: :logged, audit_required: true }
            end
          end

          private

          def proposal_store
            @proposal_store ||= Helpers::Proposal.new
          end
        end
      end
    end
  end
end
