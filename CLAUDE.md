# lex-governance

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Four-layer distributed governance protocol for the LegionIO cognitive architecture. Implements council-based proposal/voting with quorum resolution, four validation layers for action authorization, and a clean audit trail via resolved_at timestamps.

## Gem Info

- **Gem name**: `lex-governance`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::Governance`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/governance/
  version.rb
  helpers/
    layers.rb    # GOVERNANCE_LAYERS, quorum constants, PROPOSAL_CATEGORIES, valid helpers
    proposal.rb  # Proposal class - UUID-keyed proposals, vote/check_resolution/resolve_timed_out logic
  runners/
    governance.rb # create_proposal, vote_on_proposal, get_proposal, open_proposals, validate_action, timeout_proposals
  actors/
    vote_timeout.rb  # VoteTimeout - Every 300s, closes proposals past VOTE_TIMEOUT (24h)
spec/
  legion/extensions/governance/
    runners/
      governance_spec.rb
    client_spec.rb
```

## Key Constants (Helpers::Layers)

```ruby
GOVERNANCE_LAYERS   = %i[agent_validation anomaly_detection human_deliberation transparency]
MIN_COUNCIL_SIZE    = 3
QUORUM_FRACTION     = 0.66
VOTE_TIMEOUT        = 86_400  # 24 hours (not enforced in current implementation)
PROPOSAL_CATEGORIES = %i[policy_change resource_allocation access_control emergency protocol_update]
```

`quorum_met?(votes, council_size)` returns false if `council_size < MIN_COUNCIL_SIZE`, otherwise checks if votes >= `ceil(council_size * QUORUM_FRACTION)`.

## Proposal Class

`Helpers::Proposal` stores proposals in a Hash keyed by UUID.

`vote(proposal_id, voter:, approve:)` returns:
- `nil` if not found or not open
- `:already_voted` if voter in `votes_for + votes_against`
- resolution result (`:approved`, `:rejected`, or `:pending`) after adding vote

`check_resolution` (private): approved if `quorum_met?(votes_for.size)`, rejected if `quorum_met?(votes_against.size)` OR all council members voted against.

## Actors

| Actor | Interval | Runner | Method | Purpose |
|---|---|---|---|---|
| `VoteTimeout` | Every 300s | `Runners::Governance` | `timeout_proposals` | Closes proposals that have been open past VOTE_TIMEOUT (24h) |

### VoteTimeout

Every 5 minutes, fetches all open proposals and selects those where `Time.now.utc - created_at > VOTE_TIMEOUT`. For each timed-out proposal, calls `proposal_store.resolve_timed_out(proposal_id)`, which sets `status: :timed_out` and stamps `resolved_at`. Returns `{ checked: Integer, timed_out: Integer, timed_out_ids: Array }`. This actor enforces the previously-defined-but-unenforced `VOTE_TIMEOUT` constant.

## validate_action Logic

The `validate_action` runner method is a static layer-based check (not a runtime permission system). It hardcodes the response for each layer:
- `:agent_validation` -> allowed
- `:anomaly_detection` -> allowed
- `:human_deliberation` -> not allowed (requires human approval)
- `:transparency` -> allowed + audit_required flag

## Integration Points

- **lex-extinction**: governance council votes to trigger escalation levels
- **lex-consent**: `apply_tier_change` with `:access_control` category goes through governance
- **lex-conflict**: unresolvable conflicts may be escalated to governance proposals

## Development Notes

- `VOTE_TIMEOUT = 86_400` is now enforced by the `VoteTimeout` actor — the note that it was "not enforced" is superseded
- The `_context:` parameter in `validate_action` is unused (rubocop disable annotation present)
- `council_size` defaults to `MIN_COUNCIL_SIZE = 3` when not specified in `create_proposal`
- Double-vote prevention checks combined `votes_for + votes_against` list for the voter identity
- `resolve_timed_out` on `Helpers::Proposal` sets `status: :timed_out` (distinct from `:approved`/`:rejected`) and stamps `resolved_at`; returns `nil` if proposal not found or already closed
