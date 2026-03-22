# frozen_string_literal: true

module Legion
  module Extensions
    module Governance
      module Helpers
        module Authority
          AUTHORITY_REQUIRED = {
            %w[active paused] => :owner_or_manager,
            %w[paused active] => :owner_or_manager,
            %w[active retired] => :owner_or_manager
          }.freeze

          module_function

          def check_authority(principal_id:, from_state:, to_state:, worker_owner: nil, **)
            required = authority_for(from_state, to_state)
            return { allowed: true, reason: :no_authority_required } unless required
            return { allowed: true, reason: :system_principal } if principal_id == 'system'
            return { allowed: false, reason: :authority_required, required: required } if principal_id.nil?

            case required
            when :owner_or_manager
              if principal_id == worker_owner
                { allowed: true, reason: :owner_match }
              else
                { allowed: false, reason: :authority_required, required: required,
                  principal_id: principal_id, worker_owner: worker_owner }
              end
            else
              { allowed: false, reason: :authority_required, required: required }
            end
          end

          def authority_for(from_state, to_state)
            AUTHORITY_REQUIRED[[from_state, to_state]]
          end
        end
      end
    end
  end
end
