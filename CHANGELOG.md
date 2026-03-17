# Changelog

## [0.2.0] - 2026-03-17

### Added
- `Runners::ShadowAi`: scan_unregistered_extensions, check_llm_bypass_indicators, check_airb_compliance, full_scan
- `ShadowAiScan` actor: daily automated scan for shadow AI (every 86400s)
- Emits `governance.shadow_ai_detected` event when unregistered extensions, LLM bypass, or AIRB non-compliance found

## [0.1.1] - 2026-03-14

### Added
- `VoteTimeout` actor (Every 300s): times out governance proposals exceeding `VOTE_TIMEOUT` (86400s), enforcing the previously defined-but-not-enforced constant via `timeout_proposals` in `runners/governance.rb`

## [0.1.0] - 2026-03-13

### Added
- Initial release
