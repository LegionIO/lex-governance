# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Governance::Helpers::Airb do
  before do
    allow(Legion::Settings).to receive(:dig).with(:governance, :airb, :backend).and_return(:settings)
  end

  describe '.fetch' do
    context 'when no AIRB record exists' do
      before { Legion::Settings[:airb_approvals] = {} }

      it 'returns unknown status' do
        record = described_class.fetch(worker_id: 'w1')
        expect(record.status).to eq(:unknown)
        expect(record.risk_tier).to eq(:low)
      end
    end

    context 'when AIRB record exists' do
      before do
        Legion::Settings[:airb_approvals] = {
          'w1' => { airb_id: 'AIRB-001', status: 'approved', risk_tier: 'high' }
        }
      end

      it 'returns the configured status' do
        record = described_class.fetch(worker_id: 'w1')
        expect(record.status).to eq(:approved)
        expect(record.risk_tier).to eq(:high)
        expect(record.airb_id).to eq('AIRB-001')
      end
    end

    context 'with stub backend' do
      before { allow(Legion::Settings).to receive(:dig).with(:governance, :airb, :backend).and_return(:stub) }

      it 'always returns approved' do
        record = described_class.fetch(worker_id: 'any')
        expect(record.status).to eq(:approved)
      end
    end
  end
end
