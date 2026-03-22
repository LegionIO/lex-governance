# lex-governance: Policy Decision Point for LegionIO

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that serves as the policy decision point for worker lifecycle transitions. Enforces AIRB compliance, council approval, and caller authority checks. Integrates with lex-audit for approval workflows. All behavior is settings-driven and configurable.

**GitHub**: https://github.com/LegionIO/lex-governance
**License**: MIT
**Version**: 0.3.0

## Architecture

```
Legion::Extensions::Governance
├── Runners/
│   └── Governance            # review_transition (central), check_airb_approval, check_council_approval,
│                             #   check_authority_level, settings helpers (governance_enabled?, auto_submit?,
│                             #   council_required_transitions)
└── Helpers/
    ├── Airb                  # AIRB status model, pluggable backend (settings/stub), risk tier gating
    ├── Council               # Delegates to lex-audit ApprovalQueue; permissive when lex-audit absent
    └── Authority             # Validates caller authority level (owner_or_manager) per transition
```

## Key Files

| Path | Purpose |
|------|---------|
| `lib/legion/extensions/governance.rb` | Entry point |
| `lib/legion/extensions/governance/runners/governance.rb` | All runner methods: review_transition, 3 checks, settings helpers |
| `lib/legion/extensions/governance/helpers/airb.rb` | AIRB constants, AirbRecord struct, pluggable fetch |
| `lib/legion/extensions/governance/helpers/council.rb` | Council delegation to lex-audit ApprovalQueue |
| `lib/legion/extensions/governance/helpers/authority.rb` | Authority validation with AUTHORITY_REQUIRED mapping |

## Settings

All under the `governance` key:

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

- `enabled: false` skips all governance checks
- `auto_submit_approval: false` blocks without creating approval requests
- `bypass_in_dev: true` skips governance when `Legion::Settings.dev_mode?` is true
- `council.required_transitions: null` uses defaults from `Lifecycle::GOVERNANCE_REQUIRED`; explicit list overrides
- `airb.backend: "stub"` returns approved/low-risk for all workers (testing)

## Integration Points

- `Lifecycle.transition!` calls `review_transition` when lex-governance is loaded (guarded with `defined?`)
- Raises `GovernanceBlocked` when any check fails
- Auto-submits to lex-audit ApprovalQueue when council approval is required and `auto_submit_approval` is true
- Falls back to legacy `GovernanceRequired`/`AuthorityRequired` when lex-governance is not loaded

## Testing

```bash
bundle install
bundle exec rspec     # 33 examples, 0 failures
bundle exec rubocop   # 0 offenses
```

---

**Maintained By**: Matthew Iverson (@Esity)
