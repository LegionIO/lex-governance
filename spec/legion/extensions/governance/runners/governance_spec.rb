# frozen_string_literal: true

require 'legion/extensions/governance/client'

RSpec.describe Legion::Extensions::Governance::Runners::Governance do
  let(:client) { Legion::Extensions::Governance::Client.new }

  describe '#create_proposal' do
    it 'creates a proposal' do
      result = client.create_proposal(category: :policy_change, description: 'test', proposer: 'agent-1')
      expect(result[:proposal_id]).to match(/\A[0-9a-f-]{36}\z/)
      expect(result[:status]).to eq(:open)
    end

    it 'rejects invalid category' do
      result = client.create_proposal(category: :invalid, description: 'test', proposer: 'agent-1')
      expect(result[:error]).to eq(:invalid_category)
    end
  end

  describe '#vote_on_proposal' do
    it 'records a vote' do
      prop = client.create_proposal(category: :policy_change, description: 'test', proposer: 'agent-1', council_size: 3)
      result = client.vote_on_proposal(proposal_id: prop[:proposal_id], voter: 'agent-2', approve: true)
      expect(result[:voted]).to be true
    end

    it 'prevents double voting' do
      prop = client.create_proposal(category: :policy_change, description: 'test', proposer: 'agent-1', council_size: 3)
      client.vote_on_proposal(proposal_id: prop[:proposal_id], voter: 'agent-2', approve: true)
      result = client.vote_on_proposal(proposal_id: prop[:proposal_id], voter: 'agent-2', approve: true)
      expect(result[:error]).to eq(:already_voted)
    end

    it 'approves with quorum' do
      prop = client.create_proposal(category: :policy_change, description: 'test', proposer: 'agent-1', council_size: 3)
      client.vote_on_proposal(proposal_id: prop[:proposal_id], voter: 'v1', approve: true)
      result = client.vote_on_proposal(proposal_id: prop[:proposal_id], voter: 'v2', approve: true)
      expect(result[:resolution]).to eq(:approved)
    end
  end

  describe '#validate_action' do
    it 'allows agent_validation' do
      result = client.validate_action(layer: :agent_validation, action: 'test')
      expect(result[:allowed]).to be true
    end

    it 'blocks human_deliberation' do
      result = client.validate_action(layer: :human_deliberation, action: 'test')
      expect(result[:allowed]).to be false
    end

    it 'rejects invalid layer' do
      result = client.validate_action(layer: :invalid, action: 'test')
      expect(result[:error]).to eq(:invalid_layer)
    end
  end

  describe '#open_proposals' do
    it 'lists open proposals' do
      client.create_proposal(category: :policy_change, description: 'test', proposer: 'agent-1')
      result = client.open_proposals
      expect(result[:count]).to eq(1)
    end
  end
end
