# Changelog

## [0.3.2] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.3.1] - 2026-03-22

### Changed
- Add legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport as runtime dependencies
- Update spec_helper with real sub-gem helper stubs (replaces hand-rolled Legion::Logging and Legion::Extensions::Core stubs)

## [0.3.0] - 2026-03-22

### Added
- `review_transition`: central governance check running AIRB, council, and authority gates
- `Helpers::Council`: delegates approval workflow to lex-audit ApprovalQueue (permissive when lex-audit absent)
- `Helpers::Authority`: validates caller has required authority level for transition
- Configurable settings: `governance.enabled`, `governance.auto_submit_approval`, `governance.bypass_in_dev`, `governance.council.required_transitions`
- Auto-submit approval requests to lex-audit when transitions are blocked (configurable)

## [0.2.1] - 2026-03-22

### Added
- CI workflow for automated testing and gem release

## [0.1.0] - 2026-03-21

### Added
- `Helpers::Airb`: AIRB status model with pluggable backend (settings/stub)
- `check_airb_approval(worker_id:)`: governance gate that blocks unapproved high/critical-risk workers
- AIRB constants: `REQUIRE_AIRB_APPROVAL`, `ACCEPTABLE_STATUSES` per risk tier
- Settings-based AIRB backend reads from `settings[:airb_approvals]`

### Security
- High/critical-risk workers must have AIRB approval (:approved or :conditional) to execute
- Critical-risk workers require :approved only (not :conditional)
