#!/usr/bin/env sh
# Build xz on Alpine (musl-static).
# Out-of-tree build into /tmp/build so upstream/ stays clean.
#
# CI invokes:
#   docker run --rm --platform linux/$ARCH -v "$PWD":/w -w /w \
#     alpine:3.20 sh -c 'apk add --no-cache bash >/dev/null
#                         && bash /w/scripts/build-alpine.sh'
set -eu

apk add --no-cache build-base autoconf automake libtool \
	autoconf-archive gettext-dev pkgconfig bash python3

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SRC="$ROOT/upstream/xz"
BUILD_DIR="${BUILD_DIR:-/tmp/build}"

# Clean stale state from prior builds
( cd "$SRC" && find . -maxdepth 3 -name Makefile -delete -o -name config.h -delete -o -name config.status -delete 2>/dev/null || true )

# xz ships a configure script in its tarball — use it directly.
# If missing, fall back to autogen.sh.
if [ ! -x "$SRC/configure" ]; then
	echo "==> running autoreconf -fi (xz 5.8.3 ships only configure.ac, no configure)"
	# Use autoreconf instead of upstream autogen.sh — autogen.sh runs
	# autoconf BEFORE automake (wrong order), which fails with
	# "src/xz/Makefile.in not found". autoreconf runs them in the
	# correct order: aclocal → libtoolize → automake → autoconf.
	( cd "$SRC" && autoreconf -fi )
fi

mkdir -p "$BUILD_DIR"

echo "==> configure (musl-static + minimal)"
# Add -static to LDFLAGS so the resulting xz binary is fully static
# (no /lib/ld-musl-x86_64.so.1 dynamic linker dependency). xz-utils
# doesn't have an --enable-static-bin option like iperf3, so we
# append it manually. musl-only — on macOS ld rejects -static.
# Note: ${LDFLAGS:-} handles unset (set -eu makes unbound vars fail).
( cd "$BUILD_DIR" && LDFLAGS="-static ${LDFLAGS:-}" "$SRC/configure" --srcdir="$SRC" \
	--disable-dependency-tracking \
	--disable-silent-rules \
	--disable-shared \
	--enable-static \
	--disable-doc \
	--disable-nls )

echo "==> post-configure sed: force static liblzma link (xz-utils doesn't honor -static in libtool)"

# Use portable sed (-i with no arg = GNU sed; for BSD sed, this would
# be a backup suffix). Alpine's busybox sed uses GNU syntax.
( cd "$BUILD_DIR" && \
	find . -name Makefile -print0 | xargs -0 sed -i \
		-e 's|../../src/liblzma/liblzma\.la|../../src/liblzma/.libs/liblzma.a|g' \
		-e 's|src/liblzma/liblzma\.la|src/liblzma/.libs/liblzma.a|g' \
		-e 's|liblzma\.la|liblzma.a|g' \
)

echo "==> make"
# Pass LDFLAGS to make too (not just configure) so the link step
# actually uses -static. xz-utils' libtool bakes LDFLAGS at configure
# time; we override at make.
( cd "$BUILD_DIR" && make -j"$(getconf _NPROCESSORS_ONLN)" LDFLAGS="-static" )

echo "==> strip"
strip "$BUILD_DIR/src/xz/xz" "$BUILD_DIR/src/xzdec/xzdec" "$BUILD_DIR/src/lzmainfo/lzmainfo" 2>/dev/null || true

echo "==> built:"
ls -la "$BUILD_DIR/src/xz/xz"