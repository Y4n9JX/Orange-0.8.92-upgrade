# Orange 0.8.92 Upgrade Workspace

This repository is a clean FlClash 0.8.92/main baseline intended for migrating Orange/XBoard custom features forward.

## Baseline

- Upstream: https://github.com/chen08209/FlClash
- Target: FlClash `v0.8.92` / current main baseline at repository creation time

## Goal

Use this repository to update Orange onto the newer FlClash base, especially Windows TUN/service/core fixes, while porting Orange features incrementally.

## Migration order

1. Keep the upstream FlClash base buildable.
2. Port Orange branding/config tooling only after baseline builds.
3. Port XBoard remote config and SDK integration.
4. Port auth/subscription/invite/payment/support features.
5. Re-test Android, Windows TUN, macOS packaging.

## Notes

Do not commit private deployment config such as `assets/config/xboard.config.yaml` or real encryption keys.
