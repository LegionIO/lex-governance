# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Governance::Runners::Governance do
  let(:host) { Object.new.extend(described_class) }

  before { Legion::Settings.reset! }

  describe '#governance_enabled?' do
    it 'returns true by default' do
      expect(host.governance_enabled?).to be true
    end

    it 'returns false when governance.enabled is false' do
      Legion::Settings[:governance] = { enabled: false }
      expect(host.governance_enabled?).to be false
    end

    it 'skips in dev mode when bypass_in_dev is true' do
      Legion::Settings[:governance] = { bypass_in_dev: true }
      allow(Legion::Settings).to receive(:respond_to?).with(:dev_mode?).and_return(true)
      allow(Legion::Settings).to receive(:dev_mode?).and_return(true)
      expect(host.governance_enabled?).to be false
    end
  end

  describe '#auto_submit?' do
    it 'returns true by default' do
      expect(host.auto_submit?).to be true
    end

    it 'returns false when governance.auto_submit_approval is false' do
      Legion::Settings[:governance] = { auto_submit_approval: false }
      expect(host.auto_submit?).to be false
    end
  end

  describe '#council_required_transitions' do
    it 'returns nil by default (use Lifecycle defaults)' do
      expect(host.council_required_transitions).to be_nil
    end

    it 'returns configured list when set' do
      transitions = [%w[active terminated]]
      Legion::Settings[:governance] = { council: { required_transitions: transitions } }
      expect(host.council_required_transitions).to eq(transitions)
    end
  end
end
