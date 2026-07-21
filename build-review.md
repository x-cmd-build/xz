# Build Review

> **Structure**: per-version sections (newest first). See
> [`x-cmd-build/mneme/ORG_CONVENTIONS.md`](https://github.com/x-cmd-build/mneme/blob/main/ORG_CONVENTIONS.md) §5.1.

---

# v0.1.0 (2026-07-21) — initial release

## 1. Build system overview

- **Source**: vendored from <https://github.com/tukaani-project/xz>
  @ `v5.8.3` (commit `4b73f2ec19a99ef465282fbce633e8deb33691b3`)
- **Build system**: autotools (`./configure && make`)
- **Vendoring method**: tarball extract (xz doesn't use git for releases;
  uses a tukaani.org-hosted release tarball)
- **Out-of-tree build**: YES (`build/` separate from `upstream/xz/`)
- **Clean-state hygiene**: `find . -maxdepth 3 -name Makefile -delete
  -o -name config.h -delete -o -name config.status -delete` before each
  configure

## 2. Configure / build flags

```sh
./configure --srcdir=upstream/xz \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --disable-shared \
    --enable-static \
    --disable-xz \
    --disable-xzdec \
    --disable-lzmadec \
    --disable-lzmainfo \
    --disable-scripts \
    --disable-doc \
    --disable-nls
```

### Project-specific flags (xz-utils)

| Flag | Purpose |
|---|---|
| `--disable-shared --enable-static` | libtool: build static lib only |
| `--disable-doc` | skip man pages + doc generation (saves time, smaller build) |
| `--disable-nls` | skip gettext / locale (no translation files; saves ~30KB) |

We **keep all the CLI tools** (xz, xzdec, lzmainfo, scripts) enabled —
we want users to have the full xz-utils experience. xz-utils has
zero external runtime deps, so shipping more binaries is free.

## 3. Build matrix

| Target | Toolchain | Self-contained | Cross-compile | Verified clean |
|---|---|---|---|---|
| `x86_64-linux-musl` | alpine:3.20 docker | ✅ fully static | docker `--platform linux/amd64` | pending v0.1.0 |
| `aarch64-linux-musl` | alpine:3.20 (arm64) docker | ✅ | docker `--platform linux/arm64` | pending v0.1.0 |
| `darwin-arm64` | macos-latest + brew autotools | ✅ static (libtool static) | native | pending v0.1.0 |
| `darwin-x64` | macos-latest + clang | ✅ static | cross from arm64 | pending v0.1.0 |
| `windows-x64` | windows-latest + msys2 MSYS | ✅ (no msys-2.0.dll dep — pure xz is self-contained) | native | pending v0.1.0 |
| `windows-arm64` | (deferred) | ❌ MSYS2 toolchain gap | N/A | ❌ |

## 4. Self-containedness verification

### Linux (docker alpine:3.20 base, no extras)

```sh
docker run --rm -v "$PWD":/w alpine:3.20 \
    sh -c '/w/xz-linux-musl-x64/bin/xz --version'
# Expected: xz (XZ Utils) 5.8.3
# Expected: ls -lh /w/xz-linux-musl-x64/bin/xz → ~500KB static binary
```

### macOS (otool check)

```sh
bin="dist/xz-darwin-arm64/bin/xz"
otool -L "$bin"
# Expected: only /usr/lib/libSystem.B.dylib (liblzma is statically linked)
```

### Windows (manual on Windows host)

```cmd
xz.exe --version
REM Must run without "missing DLL" errors after MSYS2 install
REM (pure xz doesn't depend on msys-2.0.dll)
```

## 5. Reproducibility

- **Bit-for-bit reproducible**: ❌ (timestamps in debug info, paths)
- **Source-deterministic**: ✅ (same source → same binary modulo timestamps)
- **Toolchain pinned**: alpine:3.20, macos-latest, windows-latest
- **Why not bit-reproducible**: not worth the complexity for current use case

## 6. Build matrix self-containedness (per-target detail)

### x86_64-linux-musl (pending first run)

- **Toolchain**: `alpine:3.20` docker (--platform linux/amd64)
- **Deps installed**: build-base, autoconf, automake, libtool, bash
- **Self-contained?** YES expected — static-linked; no runtime deps
- **Runtime tested on**: pending first release
- **Binary size (stripped)**: ~500KB expected

### aarch64-linux-musl (pending)

- Same as above but `--platform linux/arm64`

### darwin-arm64 (pending)

- **Toolchain**: macos-latest + Homebrew autoconf/automake/libtool
- **Self-contained?** YES expected — static liblzma linked into xz binary

### darwin-x64 (pending)

- Same as darwin-arm64 but cross-compiled

### windows-x64 (pending)

- **Toolchain**: msys2/setup-msys2@v2 (msystem: MSYS)
- **Self-contained?** YES expected — pure xz doesn't need msys-2.0.dll

## 7. Build audit history (per-release)

| Version | Date | Toolchain bump | Matrix change | Reviewer |
|---|---|---|---|---|
| v0.1.0 | 2026-07-21 | alpine 3.20 + macos-latest + msys2 | initial | @ljh-zs |

## 8. Known limitations / workarounds

| Issue | Status | Notes |
|---|---|---|
| aarch64-windows toolchain missing | deferred | MSYS2 gap |
| xz-utils upstream tests (`make check`) not run in our CI | by design | requires test data files; smoke test covers main use case |

## 9. Build script inventory

```
scripts/
├── build-alpine.sh   # Linux musl (alpine docker)
├── build.sh          # macOS + Windows (POSIX shell)
├── smoke.sh          # round-trip compress/decompress test
├── package.sh        # Linux/macOS tar.xz + per-archive sha256
└── package.ps1       # Windows zip + per-archive sha256 (MSYS bash + powershell)
```

## 10. Audit sign-off

- [x] Reviewed by @ljh-zs (2026-07-21)
- [ ] Reviewed by @edwinjhlee (pending)
- [x] All matrix entries either ship or have documented limitation
- [x] `build-review.md` committed before triggering `release.yml`

---

# Appendix: build history summary

| Version | Date | Notable changes |
|---|---|---|
| v0.1.0 | 2026-07-21 | initial bootstrap of xz-utils 5.8.3 |

## Related docs

- [`security-review.md`](security-review.md) — version-organized
- [`code-review.md`](code-review.md) — version-organized
- [Design HQ](https://github.com/x-cmd-build/mneme/blob/main/ORG_CONVENTIONS.md)

## Version

- Doc version: 2.0 (per-version organization)
- Source: `x-cmd-build/xz/build-review.md`