# lex-governance

Policy decision point for LegionIO worker lifecycle governance. Enforces AIRB compliance gates, council approval, and caller authority checks before allowing lifecycle transitions.

## Overview

`lex-governance` integrates with the LegionIO lifecycle system. When loaded, `Lifecycle.transition!` calls `review_transition` before applying any state change. If a compliance check fails, a `GovernanceBlocked` error is raised.

Three checks are applied in sequence:

1. **AIRB** — AI risk board status gate; high-risk workers require explicit AIRB approval
2. **Council** — approval workflow check (delegates to `lex-audit` `ApprovalQueue` when available)
3. **Authority** — validates the caller has sufficient authority for the requested transition

All checks are settings-driven and can be individually disabled.

## Installation

Add to your Gemfile:

```ruby
gem 'lex-governance'
```

## Configuration

Settings under the `governance` key:

```json
{
  "governance": {
    "enabled": true,
    "auto_submit_approval": true,
    "bypass_in_dev": false,
    "airb": { "backend": "settings" },
    "council": { "required_transitions": null }
  }
}
```

| Setting | Default | Purpose |
|---------|---------|---------|
| `enabled` | `true` | Set to `false` to skip all governance checks |
| `auto_submit_approval` | `true` | Auto-submit to lex-audit when council approval is needed |
| `bypass_in_dev` | `false` | Skip governance when `Legion::Settings.dev_mode?` is true |
| `airb.backend` | `"settings"` | `"settings"` reads AIRB records from settings; `"stub"` approves everything |
| `council.required_transitions` | `null` | Override which transitions require council; null uses lifecycle defaults |

## Usage

Governance runs automatically when `lex-governance` is loaded. To check manually:

```ruby
require 'legion/extensions/governance'

reviewer = Class.new { include Legion::Extensions::Governance::Runners::Governance }.new

# Full lifecycle gate (used by Lifecycle.transition!)
result = reviewer.review_transition(
  worker_id:   'worker-123',
  transition:  :start,
  caller_role: :manager
)
# => { approved: true } or raises GovernanceBlocked

# Individual checks
reviewer.check_airb_approval(worker_id: 'worker-123', transition: :start)
reviewer.check_council_approval(worker_id: 'worker-123', transition: :start)
reviewer.check_authority_level(transition: :start, caller_role: :manager)
```

## Development

```bash
bundle install
bundle exec rspec      # 33 examples, 0 failures
bundle exec rubocop    # 0 offenses
```

## Related

- `lex-audit` (`extensions-agentic/`): provides `ApprovalQueue` for council approval workflows
- `LegionIO` core: `Lifecycle.transition!` calls `review_transition` when this gem is loaded

## License

MIT
