# frozen_string_literal: true

require 'spec_helper'

Helpers = Legion::Extensions::Governance::Helpers

RSpec.describe Legion::Extensions::Governance::Runners::Governance do
  let(:host) { Object.new.extend(described_class) }

  before do
    allow(Legion::Settings).to receive(:dig).with(:governance, :airb, :backend).and_return(:settings)
  end

  describe '#check_airb_approval' do
    it 'allows low-risk worker with unknown status' do
      allow(Helpers::Airb).to receive(:fetch).and_return(
        Helpers::Airb::AirbRecord.new(worker_id: 'w1', status: :unknown, risk_tier: :low)
      )
      result = host.check_airb_approval(worker_id: 'w1')
      expect(result[:allowed]).to be true
    end

    it 'blocks high-risk worker with pending status' do
      allow(Helpers::Airb).to receive(:fetch).and_return(
        Helpers::Airb::AirbRecord.new(worker_id: 'w1', status: :pending, risk_tier: :high)
      )
      result = host.check_airb_approval(worker_id: 'w1')
      expect(result[:allowed]).to be false
      expect(result[:reason]).to eq(:airb_blocked)
    end

    it 'allows high-risk worker with approved status' do
      allow(Helpers::Airb).to receive(:fetch).and_return(
        Helpers::Airb::AirbRecord.new(worker_id: 'w1', status: :approved, risk_tier: :high)
      )
      result = host.check_airb_approval(worker_id: 'w1')
      expect(result[:allowed]).to be true
    end

    it 'blocks critical-risk worker with conditional status' do
      allow(Helpers::Airb).to receive(:fetch).and_return(
        Helpers::Airb::AirbRecord.new(worker_id: 'w1', status: :conditional, risk_tier: :critical)
      )
      result = host.check_airb_approval(worker_id: 'w1')
      expect(result[:allowed]).to be false
    end

    it 'allows critical-risk worker with approved status' do
      allow(Helpers::Airb).to receive(:fetch).and_return(
        Helpers::Airb::AirbRecord.new(worker_id: 'w1', status: :approved, risk_tier: :critical)
      )
      result = host.check_airb_approval(worker_id: 'w1')
      expect(result[:allowed]).to be true
    end
  end
end
