# xz — portable binary distribution

Vendored **[xz-utils](https://github.com/tukaani-project/xz)** @ **5.8.3**
(post-CVE-2024-3094) — portable binary distribution for the `x-cmd`
package ecosystem.

## Install

```sh
# macOS / Linux (anywhere with `x`):
x eget x-cmd-build/xz --to /usr/local/bin/xz

# Manual:
# 1. Go to https://github.com/x-cmd-build/xz/releases
# 2. Download the asset matching your platform
# 3. Unpack; put `xz` (or `xz.exe`) on your PATH
```

### Asset naming

| File | Platform |
|---|---|
| `xz-linux-musl-x64.tar.xz` | x86_64 Linux (Alpine / glibc, statically linked) |
| `xz-linux-musl-arm64.tar.xz` | aarch64 Linux |
| `xz-darwin-x64.tar.xz` | x86_64 macOS |
| `xz-darwin-arm64.tar.xz` | Apple Silicon macOS |
| `xz-windows-x64.zip` | x86_64 Windows (MSYS) |

Each archive contains `bin/xz` (or `bin/xz.exe`) plus `LICENSE`,
`NOTICE.md`, and this README.

## Use

```sh
# Compress / decompress
xz file.txt            # → file.txt.xz (delete original)
xz -d file.txt.xz      # → file.txt
xz -k file.txt         # keep original
xz -9 file.txt         # max compression

# Streaming
tar -cf - src/ | xz > src.tar.xz
xz -dc src.tar.xz | tar -xf -
```

## CVE-2024-3094 status

xz-utils 5.6.0 and 5.6.1 contained a malicious backdoor (CVE-2024-3094).
**5.8.3 is clean** — verified via source review at bootstrap (see
[`security-review.md`](security-review.md) for details).

We pin to 5.8.3+ to avoid the entire CVE-2024-3094 version range
(5.6.0, 5.6.1). Upgrade policy:

| Range | Status |
|---|---|
| ≤ 5.4.x | pre-CVE, supported upstream |
| 5.5.x | pre-CVE, supported upstream |
| 5.6.0, 5.6.1 | **CVE-2024-3094 — DO NOT USE** |
| 5.6.2+ | post-CVE fix, safe |
| 5.8.x | current, recommended |

## License

- **This distribution** (`x-cmd-build/xz`): BSD-3-Clause (our wrapper)
- **xz-utils** itself: mixed — see `NOTICE.md` and `upstream/xz/COPYING*`

## See also

- xz-utils upstream: <https://github.com/tukaani-project/xz>
- CVE-2024-3094 advisory: <https://www.cve.org/CVERecord?id=CVE-2024-3094>
- Chinese README: [README.cn.md](README.cn.md)
- Design HQ: <https://github.com/x-cmd-build/mneme> (private)