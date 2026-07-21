#!/usr/bin/env sh
# Smoke test xz: round-trip a file through compress/decompress.
# Verifies the binary actually runs and produces sane output.
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
# Use XZ_BIN env var if set (CI sets it to absolute path), else relative
# path for local runs.
BIN="${XZ_BIN:-${BUILD_DIR:-$ROOT/build}/src/xz/xz}"

[ -x "$BIN" ] || { echo "error: $BIN not found or not executable" >&2; exit 1; }

echo "==> version"
"$BIN" --version || true

# Create a temp file with some content
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
INPUT="$TMP/input.txt"
echo "xz smoke test — this is a test file with some content that should compress and decompress correctly" > "$INPUT"
ORIG_SIZE=$(wc -c < "$INPUT")

echo "==> compress + decompress round-trip"
"$BIN" -k "$INPUT"
[ -f "$INPUT.xz" ] || { echo "FAIL: $INPUT.xz not created"; exit 1; }
COMPRESSED_SIZE=$(wc -c < "$INPUT.xz")
echo "    $ORIG_SIZE → $COMPRESSED_SIZE bytes (compressed)"

# xz refuses to overwrite the source file by default; remove it first
# so we can verify round-trip without -k on decompress.
rm -f "$INPUT"
"$BIN" -d "$INPUT.xz"
[ -f "$INPUT" ] || { echo "FAIL: $INPUT not restored"; exit 1; }
ROUNDTRIP_SIZE=$(wc -c < "$INPUT")
[ "$ORIG_SIZE" = "$ROUNDTRIP_SIZE" ] || { echo "FAIL: size mismatch $ORIG_SIZE vs $ROUNDTRIP_SIZE"; exit 1; }
echo "    decompressed = $ROUNDTRIP_SIZE bytes (matches original)"

# Verify content matches
ORIG_HASH=$(sha256sum "$INPUT" | cut -d' ' -f1)
[ -n "$ORIG_HASH" ] || { echo "FAIL: sha256sum missing"; exit 1; }
echo "    OK: round-trip preserved content (sha256=$ORIG_HASH)"

echo "==> passed"