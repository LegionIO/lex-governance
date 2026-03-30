# frozen_string_literal: true

module Legion
  module Extensions
    module Governance
      module Helpers
        module Airb
          AIRB_STATUSES = %i[unknown pending approved conditional denied expired].freeze

          REQUIRE_AIRB_APPROVAL = {
            low: false, medium: false, high: true, critical: true
          }.freeze

          ACCEPTABLE_STATUSES = {
            low:      %i[unknown pending approved conditional],
            medium:   %i[unknown pending approved conditional],
            high:     %i[approved conditional],
            critical: %i[approved]
          }.freeze

          AirbRecord = Struct.new(:worker_id, :airb_id, :status, :risk_tier, :expires_at, :conditions)

          module_function

          def fetch(worker_id:)
            backend = Legion::Settings.dig(:governance, :airb, :backend)&.to_sym || :settings
            case backend
            when :stub
              AirbRecord.new(worker_id: worker_id, airb_id: 'STUB', status: :approved,
                             risk_tier: :low, expires_at: nil, conditions: [])
            else
              fetch_from_settings(worker_id)
            end
          end

          def fetch_from_settings(worker_id)
            approvals = Legion::Settings[:airb_approvals] || {}
            entry = approvals[worker_id.to_s] || approvals[worker_id.to_sym]

            unless entry
              return AirbRecord.new(worker_id: worker_id, airb_id: nil, status: :unknown,
                                    risk_tier: :low, expires_at: nil, conditions: [])
            end

            AirbRecord.new(
              worker_id:  worker_id,
              airb_id:    entry[:airb_id],
              status:     (entry[:status] || 'unknown').to_sym,
              risk_tier:  (entry[:risk_tier] || 'low').to_sym,
              expires_at: entry[:expires_at],
              conditions: entry[:conditions] || []
            )
          end
        end
      end
    end
  end
end
