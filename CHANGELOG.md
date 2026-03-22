# Changelog

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
