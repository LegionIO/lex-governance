# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Governance::Helpers::Council do
  before { Legion::Settings.reset! }

  describe '.council_approved?' do
    context 'when lex-audit is not loaded' do
      before do
        hide_const('Legion::Extensions::Audit')
      end

      it 'returns allowed (permissive fallback)' do
        result = described_class.council_approved?(worker_id: 'w1', from_state: 'active', to_state: 'terminated')
        expect(result[:allowed]).to be true
        expect(result[:reason]).to eq(:audit_not_loaded)
      end
    end

    context 'when lex-audit is loaded with no approved record' do
      let(:approval_queue) { double('ApprovalQueue') }

      before do
        stub_const('Legion::Extensions::Audit::Runners::ApprovalQueue', approval_queue)
      end

      it 'returns blocked when no approved record exists' do
        allow(approval_queue).to receive(:list_pending).and_return({ success: true, approvals: [], count: 0 })
        result = described_class.council_approved?(worker_id: 'w1', from_state: 'active', to_state: 'terminated')
        expect(result[:allowed]).to be false
        expect(result[:reason]).to eq(:council_approval_required)
      end
    end
  end

  describe '.submit_approval' do
    context 'when lex-audit is not loaded' do
      before { hide_const('Legion::Extensions::Audit') }

      it 'returns success false' do
        result = described_class.submit_approval(worker_id: 'w1', from_state: 'active', to_state: 'terminated',
                                                 requester_id: 'system')
        expect(result[:success]).to be false
        expect(result[:reason]).to eq(:audit_not_loaded)
      end
    end

    context 'when lex-audit is loaded' do
      let(:approval_queue) { double('ApprovalQueue') }

      before do
        stub_const('Legion::Extensions::Audit::Runners::ApprovalQueue', approval_queue)
      end

      it 'delegates to ApprovalQueue.submit' do
        expect(approval_queue).to receive(:submit).with(
          approval_type: 'lifecycle_transition',
          payload:       { worker_id: 'w1', from_state: 'active', to_state: 'terminated' },
          requester_id:  'system'
        ).and_return({ success: true, approval_id: 42, status: 'pending' })

        result = described_class.submit_approval(worker_id: 'w1', from_state: 'active', to_state: 'terminated',
                                                 requester_id: 'system')
        expect(result[:success]).to be true
        expect(result[:approval_id]).to eq(42)
      end
    end
  end
end
