# Security Policy

## Reporting a vulnerability

xz-utils upstream vulnerabilities: report to upstream at
<https://github.com/tukaani-project/xz/issues> or via email per
upstream SECURITY policy.

This distribution (`x-cmd-build/xz`) specific vulnerabilities:

- **GitHub Security Advisories**: <https://github.com/x-cmd-build/xz/security/advisories/new>
- **GitHub Issue**: <https://github.com/x-cmd-build/xz/issues>

Please give 90 days before public disclosure, or coordinate a faster
timeline if actively exploited.

## Audit status

See [`security-review.md`](security-review.md) for the full
version-organized audit history (source-level findings, static
analysis results, runtime hardening, operational security, audit
sign-off per release).

For each release we vendor, we do a source-level review BEFORE
triggering CI build (per `feedback-ci-only-no-local-dev`) — no
build happens until the source passes review.