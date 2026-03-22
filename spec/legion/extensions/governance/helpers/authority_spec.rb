# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Governance::Helpers::Authority do
  before { Legion::Settings.reset! }

  describe '.check_authority' do
    it 'returns allowed when no authority is required for the transition' do
      result = described_class.check_authority(
        principal_id: 'user1', from_state: 'bootstrap', to_state: 'active'
      )
      expect(result[:allowed]).to be true
      expect(result[:reason]).to eq(:no_authority_required)
    end

    it 'returns allowed when principal_id is system' do
      result = described_class.check_authority(
        principal_id: 'system', from_state: 'active', to_state: 'paused'
      )
      expect(result[:allowed]).to be true
      expect(result[:reason]).to eq(:system_principal)
    end

    it 'returns blocked when principal_id is nil and authority is required' do
      result = described_class.check_authority(
        principal_id: nil, from_state: 'active', to_state: 'paused'
      )
      expect(result[:allowed]).to be false
      expect(result[:reason]).to eq(:authority_required)
    end

    it 'returns allowed for owner_or_manager when principal matches worker owner' do
      result = described_class.check_authority(
        principal_id: 'owner1', from_state: 'active', to_state: 'paused',
        worker_owner: 'owner1'
      )
      expect(result[:allowed]).to be true
      expect(result[:reason]).to eq(:owner_match)
    end

    it 'returns blocked for owner_or_manager when principal does not match worker owner' do
      result = described_class.check_authority(
        principal_id: 'user2', from_state: 'active', to_state: 'paused',
        worker_owner: 'owner1'
      )
      expect(result[:allowed]).to be false
      expect(result[:reason]).to eq(:authority_required)
    end
  end
end
