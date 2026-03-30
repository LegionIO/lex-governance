# frozen_string_literal: true

module Legion
  module Extensions
    module Governance
      module Runners
        module Governance
          extend self

          def review_transition(worker_id:, from_state:, to_state:, principal_id: nil, worker_owner: nil, **)
            return { allowed: true, skipped: true } unless governance_enabled?

            results = []
            results << check_airb_approval(worker_id: worker_id)
            results << check_council_approval(worker_id: worker_id, from_state: from_state, to_state: to_state)
            results << check_authority_level(principal_id: principal_id, from_state: from_state, to_state: to_state,
                                             worker_owner: worker_owner)

            blocked = results.reject { |r| r[:allowed] }
            return { allowed: true, checks: results } if blocked.empty?

            auto = try_auto_submit(blocked, worker_id: worker_id, from_state: from_state, to_state: to_state,
                                            requester_id: principal_id || 'system')
            { allowed: false, reasons: blocked.map { |r| r[:reason] }, checks: results, auto_submitted: auto }
          end

          def check_airb_approval(worker_id:, **)
            require_relative '../helpers/airb'
            record = Helpers::Airb.fetch(worker_id: worker_id)
            required = Helpers::Airb::REQUIRE_AIRB_APPROVAL[record.risk_tier]
            acceptable = Helpers::Airb::ACCEPTABLE_STATUSES[record.risk_tier]
            allowed = !required || acceptable.include?(record.status)

            {
              allowed:   allowed,
              worker_id: worker_id,
              airb_id:   record.airb_id,
              status:    record.status,
              risk_tier: record.risk_tier,
              reason:    allowed ? :airb_cleared : :airb_blocked
            }
          end

          def check_council_approval(worker_id:, from_state:, to_state:, **)
            require_relative '../helpers/council'
            required = council_required?(from_state, to_state)
            return { allowed: true, reason: :no_council_required } unless required

            Helpers::Council.council_approved?(worker_id: worker_id, from_state: from_state, to_state: to_state)
          end

          def check_authority_level(principal_id:, from_state:, to_state:, worker_owner: nil, **)
            require_relative '../helpers/authority'
            Helpers::Authority.check_authority(
              principal_id: principal_id, from_state: from_state, to_state: to_state,
              worker_owner: worker_owner
            )
          end

          def governance_enabled?
            gov = Legion::Settings[:governance]
            return false if gov.is_a?(Hash) && gov.key?(:enabled) && gov[:enabled] == false # rubocop:disable Legion/Extension/RunnerReturnHash

            return false if Legion::Settings.dig(:governance, :bypass_in_dev) && Legion::Settings.respond_to?(:dev_mode?) && Legion::Settings.dev_mode? # rubocop:disable Legion/Extension/RunnerReturnHash

            true
          end

          def auto_submit?
            gov = Legion::Settings[:governance]
            return true unless gov.is_a?(Hash) && gov.key?(:auto_submit_approval) # rubocop:disable Legion/Extension/RunnerReturnHash

            gov[:auto_submit_approval]
          end

          def council_required_transitions
            Legion::Settings.dig(:governance, :council, :required_transitions)
          end

          private

          def try_auto_submit(blocked, worker_id:, from_state:, to_state:, requester_id:)
            return false unless auto_submit? && blocked.any? { |r| r[:reason] == :council_approval_required } # rubocop:disable Legion/Extension/RunnerReturnHash

            require_relative '../helpers/council'
            Helpers::Council.submit_approval(worker_id: worker_id, from_state: from_state, to_state: to_state,
                                             requester_id: requester_id)
            true
          end

          def council_required?(from_state, to_state)
            custom = council_required_transitions
            if custom
              custom.any?([from_state, to_state])
            else
              governance_required_defaults.key?([from_state, to_state])
            end
          end

          def governance_required_defaults
            if defined?(Legion::DigitalWorker::Lifecycle::GOVERNANCE_REQUIRED)
              Legion::DigitalWorker::Lifecycle::GOVERNANCE_REQUIRED
            else
              { %w[retired terminated] => :council_approval, %w[active terminated] => :council_approval }
            end
          end
        end
      end
    end
  end
end
