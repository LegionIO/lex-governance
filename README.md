# lex-governance

Four-layer distributed governance protocol for brain-modeled agentic AI. Implements a council-based proposal and voting system for decisions that exceed the agent's individual authority.

## Overview

`lex-governance` provides the agent's formal decision-making structure for high-stakes choices. Instead of acting unilaterally on significant changes, the agent can submit proposals to a governance council, which votes by simple quorum. Four governance layers provide different validation mechanisms from agent self-validation through full human deliberation.

## Governance Layers

| Layer | Description | Default Outcome |
|-------|-------------|----------------|
| `agent_validation` | Agent checks its own reasoning | Allowed (self-validated) |
| `anomaly_detection` | Automated anomaly scan | Allowed (no anomaly) |
| `human_deliberation` | Human review required | **Not allowed** (requires approval) |
| `transparency` | Logged for audit trail | Allowed with audit requirement |

## Proposal Categories

`policy_change`, `resource_allocation`, `access_control`, `emergency`, `protocol_update`

## Voting

- Minimum council size: 3
- Quorum: 66% of council votes in favor (rounded up)
- Vote timeout: 24 hours
- No double-voting enforced

## Installation

Add to your Gemfile:

```ruby
gem 'lex-governance'
```

## Usage

### Creating and Voting on a Proposal

```ruby
require 'legion/extensions/governance'

# Create a proposal
result = Legion::Extensions::Governance::Runners::Governance.create_proposal(
  category: :policy_change,
  description: "Allow autonomous file writes in /tmp",
  proposer: "agent",
  council_size: 3
)
# => { proposal_id: "uuid", category: :policy_change, status: :open }

# Vote on it
Legion::Extensions::Governance::Runners::Governance.vote_on_proposal(
  proposal_id: "uuid",
  voter: "human-alice",
  approve: true
)
# => { voted: true, resolution: :pending }

# After quorum is met, resolution changes to :approved or :rejected
```

### Querying Proposals

```ruby
# Get all open proposals
Legion::Extensions::Governance::Runners::Governance.open_proposals

# Get a specific proposal
Legion::Extensions::Governance::Runners::Governance.get_proposal(proposal_id: "uuid")
```

### Validating Actions by Layer

```ruby
# Check if an action is allowed at a given governance layer
Legion::Extensions::Governance::Runners::Governance.validate_action(
  layer: :human_deliberation
)
# => { allowed: false, layer: :human_deliberation, reason: :requires_human_approval }

Legion::Extensions::Governance::Runners::Governance.validate_action(layer: :transparency)
# => { allowed: true, layer: :transparency, reason: :logged, audit_required: true }
```

## Actors

| Actor | Interval | Description |
|-------|----------|-------------|
| `VoteTimeout` | Every 300s | Closes open proposals that have exceeded `VOTE_TIMEOUT` (24h), setting their status to `:timed_out` and enforcing the vote deadline |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
