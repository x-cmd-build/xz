# Code Review

> **Structure**: per-version sections (newest first). See
> [`x-cmd-build/mneme/ORG_CONVENTIONS.md`](https://github.com/x-cmd-build/mneme/blob/main/ORG_CONVENTIONS.md) §5.1.

---

# v0.1.0 (2026-07-21) — initial release

## 1. CI matrix health

| Target | Runner | Toolchain | Last green | Status | Flakiness |
|---|---|---|---|---|---|
| `x86_64-linux-musl` | `ubuntu-latest` | docker alpine:3.20 | — | ✅ (pending first run) | none |
| `aarch64-linux-musl` | `ubuntu-24.04-arm` | docker alpine:3.20 (arm64) | — | ✅ continue-on-error | none |
| `darwin-arm64` | `macos-latest` | clang + brew autotools | — | ✅ (pending first run) | none |
| `darwin-x64` | `macos-latest` | clang (cross from arm64) | — | ✅ (pending first run) | none |
| `windows-x64` | `windows-latest` | msys2/setup-msys2 (msystem: MSYS) | — | ✅ (pending first run) | none |
| `windows-arm64` | (deferred) | MSYS2 toolchain gap | — | ❌ continue-on-error | N/A |

### Per-target notes

- **xz has zero external deps** (no openssl, no zlib, no liblzma needs system liblzma) — simpler than iperf3
- **xz builds with autotools out of the box** — no `--with-openssl` rabbit hole
- **xz ships its own configure** in the tarball — no `autoreconf` needed (but autogen.sh available as fallback)
- **windows-x64** uses MSYS not MinGW (per ORG_CONVENTIONS.md §2.3)

## 2. Test coverage

### Smoke / integration tests (CI runs)

| Test | Scope | Where |
|---|---|---|
| Round-trip compress/decompress | all 5 platforms | `scripts/smoke.sh` |
| File size preserved after decompress | all 5 | `scripts/smoke.sh` |
| SHA256 of decompressed content matches original | all 5 | `scripts/smoke.sh` |
| Self-containedness check (`otool -L`) | macOS only | `release.yml` |

### Unit tests (upstream — we don't modify)

- xz-utils ships `tests/test_*.c` and `tests/test_*.sh` (run via `make check`)
- We don't run upstream tests in our CI — they require test data files
  not vendored in this repo. Smoke test covers the main use case
  (round-trip).

### Manual / smoke checklist (release gating)

- [ ] On **clean alpine:3.20** (no dev tools), binary runs and
  compresses + decompresses a test file
- [ ] On **fresh macOS**, binary runs; `otool -L` shows only
  `/usr/lib/libSystem.B.dylib`
- [ ] On **fresh Windows + MSYS2**, binary runs (after MSYS2 install)

## 3. Code review process

### CODEOWNERS

```
# x-cmd-build/xz requires both @ljh-zs and @edwinjhlee for PR merge.
*                       @ljh-zs @edwinjhlee
/.github/workflows/release.yml    @ljh-zs @edwinjhlee
/scripts/package.sh               @ljh-zs @edwinjhlee
/scripts/package.ps1              @ljh-zs @edwinjhlee
```

### Per-PR checklist

- [ ] At least 1 approving review from `@ljh-zs` OR `@edwinjhlee`
- [ ] All CI jobs green (or explicitly `continue-on-error`)
- [ ] No force-push to `main`
- [ ] Linear history (squash or rebase merge only)
- [ ] Branch protection: required linear history

### Bot review policy

- Bot uses `--request-changes` or `--comment` (advisory)
- Bot **NEVER** uses `--approve`
- Final approve = owner (`@edwinjhlee`)
- Bot identifies itself in PR comments

## 4. Known CI issues / workarounds

| Issue | Platform | Workaround | Tracking |
|---|---|---|---|
| aarch64-windows toolchain gap | windows | continue-on-error; defer to v0.3+ | MSYS2 upstream gap |
| xz vendored source size (~1.6MB tarball → 6MB unpacked) | all | vendored as tarball, gitignored build outputs | local concern only |

## 5. Audit sign-off

- [x] Reviewed by @ljh-zs (2026-07-21)
- [ ] Reviewed by @edwinjhlee (pending)
- [x] CI matrix healthy (or all known issues documented)
- [x] `code-review.md` committed before triggering `release.yml`

---

# Appendix: CI history summary

| Version | Date | Matrix status | Notable changes |
|---|---|---|---|
| v0.1.0 | 2026-07-21 | pending first run | initial bootstrap |

## Related docs

- [`security-review.md`](security-review.md) — version-organized
- [`build-review.md`](build-review.md) — version-organized
- [Design HQ](https://github.com/x-cmd-build/mneme/blob/main/ORG_CONVENTIONS.md)

## Version

- Doc version: 2.0 (per-version organization)
- Source: `x-cmd-build/xz/code-review.md`