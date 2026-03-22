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
        end
      end
    end
  end
end
