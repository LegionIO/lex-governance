# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Governance::Runners::Governance do
  let(:host) { Object.new.extend(described_class) }

  before { Legion::Settings.reset! }

  describe '#review_transition' do
    context 'when governance is disabled' do
      before { Legion::Settings[:governance] = { enabled: false } }

      it 'returns allowed with skipped flag' do
        result = host.review_transition(worker_id: 'w1', from_state: 'active', to_state: 'terminated')
        expect(result[:allowed]).to be true
        expect(result[:skipped]).to be true
      end
    end

    context 'when all checks pass' do
      before do
        allow(host).to receive(:check_airb_approval).and_return({ allowed: true, reason: :airb_cleared })
        allow(host).to receive(:check_council_approval).and_return({ allowed: true, reason: :no_council_required })
        allow(host).to receive(:check_authority_level).and_return({ allowed: true, reason: :no_authority_required })
      end

      it 'returns allowed true with all checks' do
        result = host.review_transition(worker_id: 'w1', from_state: 'active', to_state: 'terminated')
        expect(result[:allowed]).to be true
        expect(result[:checks].length).to eq(3)
      end
    end

    context 'when AIRB blocks' do
      before do
        allow(host).to receive(:check_airb_approval).and_return({ allowed: false, reason: :airb_blocked })
        allow(host).to receive(:check_council_approval).and_return({ allowed: true, reason: :no_council_required })
        allow(host).to receive(:check_authority_level).and_return({ allowed: true, reason: :no_authority_required })
      end

      it 'returns allowed false with reasons' do
        result = host.review_transition(worker_id: 'w1', from_state: 'active', to_state: 'terminated')
        expect(result[:allowed]).to be false
        expect(result[:reasons]).to include(:airb_blocked)
      end
    end

    context 'when council blocks and auto_submit is true' do
      before do
        allow(host).to receive(:check_airb_approval).and_return({ allowed: true, reason: :airb_cleared })
        allow(host).to receive(:check_council_approval).and_return({ allowed: false, reason: :council_approval_required })
        allow(host).to receive(:check_authority_level).and_return({ allowed: true, reason: :no_authority_required })
      end

      it 'auto-submits approval request' do
        expect(Legion::Extensions::Governance::Helpers::Council).to receive(:submit_approval).with(
          worker_id: 'w1', from_state: 'active', to_state: 'terminated', requester_id: 'system'
        ).and_return({ success: true })

        result = host.review_transition(worker_id: 'w1', from_state: 'active', to_state: 'terminated',
                                        principal_id: 'system')
        expect(result[:allowed]).to be false
        expect(result[:auto_submitted]).to be true
      end
    end

    context 'when council blocks and auto_submit is false' do
      before do
        Legion::Settings[:governance] = { auto_submit_approval: false }
        allow(host).to receive(:check_airb_approval).and_return({ allowed: true, reason: :airb_cleared })
        allow(host).to receive(:check_council_approval).and_return({ allowed: false, reason: :council_approval_required })
        allow(host).to receive(:check_authority_level).and_return({ allowed: true, reason: :no_authority_required })
      end

      it 'does not auto-submit' do
        expect(Legion::Extensions::Governance::Helpers::Council).not_to receive(:submit_approval)

        result = host.review_transition(worker_id: 'w1', from_state: 'active', to_state: 'terminated')
        expect(result[:allowed]).to be false
        expect(result[:auto_submitted]).to be_falsey
      end
    end

    context 'when authority blocks' do
      before do
        allow(host).to receive(:check_airb_approval).and_return({ allowed: true, reason: :airb_cleared })
        allow(host).to receive(:check_council_approval).and_return({ allowed: true, reason: :no_council_required })
        allow(host).to receive(:check_authority_level).and_return({ allowed: false, reason: :authority_required })
      end

      it 'returns allowed false with authority reason' do
        result = host.review_transition(worker_id: 'w1', from_state: 'active', to_state: 'paused')
        expect(result[:allowed]).to be false
        expect(result[:reasons]).to include(:authority_required)
      end
    end
  end

  describe '#check_council_approval' do
    it 'returns allowed when transition does not require council' do
      result = host.check_council_approval(worker_id: 'w1', from_state: 'bootstrap', to_state: 'active')
      expect(result[:allowed]).to be true
      expect(result[:reason]).to eq(:no_council_required)
    end

    it 'delegates to Council helper when transition requires council' do
      allow(Legion::Extensions::Governance::Helpers::Council).to receive(:council_approved?).and_return(
        { allowed: false, reason: :council_approval_required }
      )
      result = host.check_council_approval(worker_id: 'w1', from_state: 'active', to_state: 'terminated')
      expect(result[:allowed]).to be false
    end
  end

  describe '#check_authority_level' do
    it 'delegates to Authority helper' do
      allow(Legion::Extensions::Governance::Helpers::Authority).to receive(:check_authority).and_return(
        { allowed: true, reason: :no_authority_required }
      )
      result = host.check_authority_level(principal_id: 'user1', from_state: 'bootstrap', to_state: 'active')
      expect(result[:allowed]).to be true
    end
  end
end
