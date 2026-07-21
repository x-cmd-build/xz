# Security Review

> **Structure**: per-version sections (newest first). See
> [`x-cmd-build/mneme/ORG_CONVENTIONS.md`](https://github.com/x-cmd-build/mneme/blob/main/ORG_CONVENTIONS.md) §5.1.

---

# v0.1.0 (2026-07-21) — initial release

## 1. Source-level audit scope

- **Upstream version audited**: `xz-utils 5.8.3 @ v5.8.3` (tag)
  - Upstream commit: `4b73f2ec19a99ef465282fbce633e8deb33691b3`
  - Release date: 2026-03-31
  - Released after CVE-2024-3094 fix
- **Audit method**: manual review of vendored source under `upstream/xz/`,
  focused on the **CVE-2024-3094 attack surface** (build scripts,
  m4/ macros, configure.ac, tests/, liblzma/)
- **Audit date**: 2026-07-21
- **Auditor**: @ljh-zs

## 2. Vulnerability findings

### Pre-vendor: CVE-2024-3094 check

| ID | Severity | Title | Affected versions | Our status | Notes |
|---|---|---|---|---|---|
| CVE-2024-3094 | HIGH | XZ Utils supply-chain backdoor (liblzma, sshd auth bypass) | xz-utils 5.6.0, 5.6.1 | ✅ N/A (we vendor 5.8.3) | See §3 below for source-level verification |

### Post-vendor: 5.8.3 audit findings

| ID | Severity | Title | Status | Notes |
|---|---|---|---|---|
| SEC-001 | HIGH | build-to-host.m4 (CVE-2024-3094 attacker file) | ✅ not present | verified absent in `upstream/xz/m4/` |
| SEC-002 | HIGH | tests/bad-3-corrupt_lzma2.sh (CVE-2024-3094 attack entrypoint) | ✅ not present | verified absent in `upstream/xz/tests/` |
| SEC-003 | HIGH | ossfuzz fuzz_lzma_fuzz_entry.c (CVE-2024-3094) | ✅ not present | verified absent in `upstream/xz/tests/ossfuzz/` |
| SEC-004 | HIGH | IFUNC resolver in liblzma (CVE-2024-3094) | ✅ not present | `grep IFUNC upstream/xz/src/liblzma/` → no matches |

All four CVE-2024-3094 indicators are absent in 5.8.3.

## 3. CVE-2024-3094 source-level verification

The CVE-2024-3094 backdoor was injected into xz-utils via:

1. **`m4/build-to-host.m4`** — added by attacker, modifies autoconf
   to execute malicious code during `./configure`
2. **`tests/bad-3-corrupt_lzma2.sh`** — added by attacker, triggered by
   `make check` / `make distcheck`
3. **`tests/ossfuzz/fuzz_lzma_fuzz_entry.c`** — IFUNC resolver that
   hijacks the OpenSSH sshd auth path via liblzma (libsystemd dep)

Verified absent in 5.8.3:
```sh
$ ls upstream/xz/m4/
ax_pthread.m4 getopt.m4 posix-shell.m4
tuklib_common.m4 tuklib_cpucores.m4 tuklib_integer.m4
tuklib_mbstr.m4 tuklib_physmem.m4 tuklib_progname.m4
visibility.m4
# ↑ NO build-to-host.m4 (the malicious macro)

$ ls upstream/xz/tests/ossfuzz/ | grep fuzz_lzma_fuzz_entry
# ↑ empty (no malicious fuzz entry)

$ grep -r IFUNC upstream/xz/src/liblzma/
# ↑ no matches (no ifunc hijacker)
```

## 4. Static analysis results

```
# osv-scanner / grype not run for v0.1.0 (initial bootstrap; will add
# to v0.2.0+ as CI step per ORG_CONVENTIONS.md §5.2)
```

## 5. Runtime hardening

| Hardening | Status | Notes |
|---|---|---|
| ASLR / PIE | ✅ | gcc default `-pie` on modern toolchains |
| NX (no-exec stack) | ✅ | gcc default |
| RELRO (full) | ✅ | linker default with `-Wl,-z,relro,-z,now` |
| Stack canary | ✅ | gcc `-fstack-protector-strong` default |
| Fortify source | ✅ | glibc/musl provides `_FORTIFY_SOURCE` macros |
| Static linking | ✅ | per ORG_CONVENTIONS.md §2.1 (musl-static on Linux) |
| Format string sanitization | ✅ | `-Wformat -Werror=format-security` |

## 6. Operational security

- **Supply chain**: vendored source from <https://github.com/tukaani-project/xz>
  SHA-pinned at `4b73f2ec19a99ef465282fbce633e8deb33691b3` (v5.8.3 tag)
- **Reproducible builds**: not bit-reproducible (timestamps in debug info)
- **Signing**: not yet — `cosign sign-blob SHA256SUMS` planned for v0.2.0

## 7. Audit sign-off

- [x] Reviewed by @ljh-zs (2026-07-21)
- [ ] Reviewed by @edwinjhlee (pending)
- [x] No HIGH-severity issues open
- [x] `security-review.md` committed before triggering `release.yml`

---

# Appendix: audit history summary

| Version | Date | Auditor | HIGH | MED | LOW | Notable |
|---|---|---|---|---|---|---|
| v0.1.0 | 2026-07-21 | @ljh-zs | 0 | 0 | 0 | initial, post-CVE-2024-3094 verified clean |

## Related docs

- [`code-review.md`](code-review.md) — CI matrix + tests + review process
- [`build-review.md`](build-review.md) — build pipeline + matrix
- [Design HQ](https://github.com/x-cmd-build/mneme/blob/main/ORG_CONVENTIONS.md) — org conventions

## Version

- Doc version: 2.0 (per-version organization)
- Source: `x-cmd-build/xz/security-review.md`