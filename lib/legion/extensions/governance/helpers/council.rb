# frozen_string_literal: true

module Legion
  module Extensions
    module Governance
      module Helpers
        module Council
          module_function

          def council_approved?(worker_id:, from_state:, to_state:, **)
            return { allowed: true, reason: :audit_not_loaded } unless defined?(Legion::Extensions::Audit::Runners::ApprovalQueue)

            record = find_approved_record(worker_id: worker_id, from_state: from_state, to_state: to_state)
            if record
              { allowed: true, reason: :council_approved, approval_id: record[:id] }
            else
              { allowed: false, reason: :council_approval_required,
                worker_id: worker_id, from_state: from_state, to_state: to_state }
            end
          end

          def submit_approval(worker_id:, from_state:, to_state:, requester_id:, **)
            return { success: false, reason: :audit_not_loaded } unless defined?(Legion::Extensions::Audit::Runners::ApprovalQueue)

            Legion::Extensions::Audit::Runners::ApprovalQueue.submit(
              approval_type: 'lifecycle_transition',
              payload:       { worker_id: worker_id, from_state: from_state, to_state: to_state },
              requester_id:  requester_id
            )
          end

          def find_approved_record(**)
            nil
          rescue StandardError => _e
            nil
          end
        end
      end
    end
  end
end
