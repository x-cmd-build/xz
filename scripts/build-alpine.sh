#!/usr/bin/env sh
# Build xz on Alpine (musl-static).
# Out-of-tree build into /tmp/build so upstream/ stays clean.
#
# CI invokes:
#   docker run --rm --platform linux/$ARCH -v "$PWD":/w -w /w \
#     alpine:3.20 sh -c 'apk add --no-cache bash >/dev/null
#                         && bash /w/scripts/build-alpine.sh'
set -eu

apk add --no-cache build-base autoconf automake libtool bash

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SRC="$ROOT/upstream/xz"
BUILD_DIR="${BUILD_DIR:-/tmp/build}"

# Clean stale state from prior builds
( cd "$SRC" && find . -maxdepth 3 -name Makefile -delete -o -name config.h -delete -o -name config.status -delete 2>/dev/null || true )

# xz ships a configure script in its tarball — use it directly.
# If missing, fall back to autogen.sh.
if [ ! -x "$SRC/configure" ]; then
	echo "==> running autogen.sh (configure missing)"
	( cd "$SRC" && sh autogen.sh )
fi

mkdir -p "$BUILD_DIR"

echo "==> configure (musl-static + minimal)"
( cd "$BUILD_DIR" && "$SRC/configure" --srcdir="$SRC" \
	--disable-dependency-tracking \
	--disable-silent-rules \
	--disable-shared \
	--enable-static \
	--disable-doc \
	--disable-nls )

echo "==> make"
( cd "$BUILD_DIR" && make -j"$(getconf _NPROCESSORS_ONLN)" )

echo "==> strip"
strip "$BUILD_DIR/src/xz/xz" "$BUILD_DIR/src/xzdec/xzdec" "$BUILD_DIR/src/lzmainfo/lzmainfo" 2>/dev/null || true

echo "==> built:"
ls -la "$BUILD_DIR/src/xz/xz"