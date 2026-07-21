# Notice

This product includes software developed by:

- **Lasse Collin** (xz-utils original author and maintainer)
- **The Tukaani Project** (xz-utils upstream home: https://tukaani.org/)

The xz-utils source code vendored under `upstream/xz/` is:

```
xz-utils 5.8.3 (stable)
Copyright (c) Lasse Collin and others
Released under multiple licenses (see upstream/xz/COPYING*):
  - 0BSD (utils)
  - LGPLv2.1+ (liblzma core)
  - GPLv2+ (some scripts, e.g., xzdiff)
```

See `upstream/xz/COPYING.0BSD`, `upstream/xz/COPYING.GPLv2`,
`upstream/xz/COPYING.GPLv3`, and `upstream/xz/COPYING.LGPLv2.1` for full
license texts.

This distribution (`x-cmd-build/xz`) only re-packages the upstream
xz-utils source code with custom build scripts for cross-platform
portable binaries. We make no modifications to the vendored source under
`upstream/xz/`.

## CVE-2024-3094 note

xz-utils 5.6.0 and 5.6.1 contained a malicious backdoor (CVE-2024-3094).
**5.8.3 (the version we vendor) is clean** — verified via source-level
review at bootstrap (see `security-review.md` for the audit log).

We pin to ≥ 5.6.2 (preferably 5.8.x) to avoid the entire CVE-2024-3094
version range.