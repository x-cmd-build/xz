#!/usr/bin/env sh
# Build xz on host (macOS) or in CI for Windows MSYS.
# Out-of-tree build into BUILD_DIR (default ./build).
#
# Used by .github/workflows/{build-and-test,release}.yml
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SRC="${XZ_SRC:-$ROOT/upstream/xz}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"

JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.nproc 2>/dev/null || echo 4)"

# Clean stale state from prior builds
( cd "$SRC" && find . -maxdepth 3 -name Makefile -delete -o -name config.h -delete -o -name config.status -delete 2>/dev/null || true )

if [ ! -x "$SRC/configure" ]; then
	( cd "$SRC" && autoreconf -fi )
fi

mkdir -p "$BUILD_DIR"

echo "==> configure"
( cd "$BUILD_DIR" && "$SRC/configure" --srcdir="$SRC" \
	--disable-dependency-tracking \
	--disable-silent-rules \
	--disable-shared \
	--enable-static \
	--disable-doc \
	--disable-nls )

echo "==> make"
( cd "$BUILD_DIR" && make -j"$JOBS" )

echo "==> strip"
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
	strip "$BUILD_DIR/src/xz/xz" 2>/dev/null || true
elif [ "${XZ_OS_HINT:-}" = "msys" ]; then
	strip "$BUILD_DIR/src/xz/.libs/xz.exe" 2>/dev/null || true
fi

echo "==> built:"
ls -la "$BUILD_DIR/src/xz/xz" 2>/dev/null || ls -la "$BUILD_DIR/src/xz/.libs/xz.exe" 2>/dev/null