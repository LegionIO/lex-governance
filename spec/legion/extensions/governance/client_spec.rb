# frozen_string_literal: true

require 'legion/extensions/governance/client'

RSpec.describe Legion::Extensions::Governance::Client do
  it 'responds to governance runner methods' do
    client = described_class.new
    expect(client).to respond_to(:create_proposal)
    expect(client).to respond_to(:vote_on_proposal)
    expect(client).to respond_to(:get_proposal)
    expect(client).to respond_to(:open_proposals)
    expect(client).to respond_to(:validate_action)
  end
end
