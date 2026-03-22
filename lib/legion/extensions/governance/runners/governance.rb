# frozen_string_literal: true

module Legion
  module Extensions
    module Governance
      module Runners
        module Governance
          def check_airb_approval(worker_id:, **)
            require_relative '../helpers/airb'
            record = Helpers::Airb.fetch(worker_id: worker_id)
            required = Helpers::Airb::REQUIRE_AIRB_APPROVAL[record.risk_tier]
            acceptable = Helpers::Airb::ACCEPTABLE_STATUSES[record.risk_tier]
            allowed = !required || acceptable.include?(record.status)

            {
              allowed: allowed,
              worker_id: worker_id,
              airb_id: record.airb_id,
              status: record.status,
              risk_tier: record.risk_tier,
              reason: allowed ? :airb_cleared : :airb_blocked
            }
          end

          def governance_enabled?
            gov = Legion::Settings[:governance]
            return false if gov.is_a?(Hash) && gov.key?(:enabled) && gov[:enabled] == false

            if Legion::Settings.dig(:governance, :bypass_in_dev)
              return false if Legion::Settings.respond_to?(:dev_mode?) && Legion::Settings.dev_mode?
            end

            true
          end

          def auto_submit?
            gov = Legion::Settings[:governance]
            return true unless gov.is_a?(Hash) && gov.key?(:auto_submit_approval)

            gov[:auto_submit_approval]
          end

          def council_required_transitions
            Legion::Settings.dig(:governance, :council, :required_transitions)
          end
        end
      end
    end
  end
end
