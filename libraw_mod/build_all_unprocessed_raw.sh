#!/usr/bin/env bash
#############################################################################
# build_all_unprocessed_raw.sh
#
# Builds "unprocessed_raw" (your fixed FITS-writing version) for:
#   - Linux   x86_64                -> out/linux-x86_64/unprocessed_raw-astap
#   - Linux   x86_32 (i386, -m32)   -> out/linux-x86_32/unprocessed_raw-astap
#   - Linux   aarch64 (cross)       -> out/aarch64/unprocessed_raw-astap
#   - Linux   armhf   (cross)       -> out/armhf/unprocessed_raw-astap
#   - Windows x86_64  (mingw)       -> out/win64/unprocessed_raw.exe
#   - Windows x86_32  (mingw)       -> out/win32/unprocessed_raw.exe
#
# MacOS is intentionally NOT included: cross-compiling to MacOS from Linux
# needs Apple's proprietary SDK (only obtainable via Xcode on a real Mac,
# and licensed for use on Apple hardware only) -- there's no free/legal
# cross-toolchain equivalent to what aarch64/armhf/mingw give us here.
# Build MacOS natively (see your own "Mac" instructions) or on a macOS CI
# runner instead.
#
# Usage:
#   1. Put your fixed unprocessed_raw.cpp next to this script
#      (or set SRC_CPP below to its path).
#   2. ./build_all_unprocessed_raw.sh
#############################################################################
set -euo pipefail

REPO_URL="https://github.com/han-k59/LibRaw-with-16-bit-FITS-support"
WORKDIR="$(pwd)/cross-build-work"
OUTDIR="$(pwd)/out"
SRC_CPP="$(pwd)/unprocessed_raw.cpp"   # your fixed source file
LINUX_BINNAME="unprocessed_raw-astap"  # renamed Linux output, per your request

# ---------------------------------------------------------------------------
# 1. Install toolchains (Debian/Ubuntu). Comment out if already present.
# ---------------------------------------------------------------------------
install_toolchains() {
    echo "==> Installing toolchains (requires sudo)..."
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    export NEEDRESTART_SUSPEND=1
    sudo -E apt-get update
    sudo -E apt-get install -y \
        git autoconf automake libtool pkg-config build-essential \
        gcc-i686-linux-gnu g++-i686-linux-gnu \
        crossbuild-essential-arm64 \
        crossbuild-essential-armhf \
        mingw-w64
}

# ---------------------------------------------------------------------------
# 2. Build one autotools (Linux) target.
#    $1 = arch label (used for the work/out subdirectory)
#    $2 = --host triplet, or "" for a native build (x86_64, x86_32 via -m32)
#    $3 = C compiler   (may include flags, e.g. "gcc -m32")
#    $4 = C++ compiler (may include flags, e.g. "g++ -m32")
# ---------------------------------------------------------------------------
build_linux_target() {
    local arch="$1" triplet="$2" cc="$3" cxx="$4"
    local src_dir="${WORKDIR}/${arch}"

    echo "############################################################"
    echo "## Building Linux ${arch} (host=${triplet:-native})"
    echo "############################################################"

    rm -rf "${src_dir}"
    git clone --depth 1 "${REPO_URL}" "${src_dir}"
    cp "${SRC_CPP}" "${src_dir}/samples/unprocessed_raw.cpp"

    pushd "${src_dir}" >/dev/null

    autoreconf --install

    local host_arg=()
    if [ -n "${triplet}" ]; then
        host_arg=(--host="${triplet}")
    fi

    # --disable-zlib: applied uniformly across every Linux target (not just
    #   the cross ones) so all four builds behave identically -- configure's
    #   pkg-config zlib check otherwise risks picking up the wrong arch's
    #   zlib.pc and failing the final link with "cannot find -lz". Not
    #   needed by unprocessed_raw (only affects deflate-compressed DNGs).
    # LDFLAGS="-static-libgcc -static-libstdc++": statically embeds the C++
    #   runtime in every binary instead of depending on a matching target
    #   libstdc++ -- fixes "undefined reference to operator new / __cxa_*"
    #   seen when cross-linking, and also makes the native binaries more
    #   portable across different Linux distros/glibc versions.
    ./configure \
        "${host_arg[@]}" \
        --enable-shared=no \
        --disable-zlib \
        CC="${cc}" \
        CXX="${cxx}" \
        LDFLAGS="-static-libgcc -static-libstdc++"

    make clean || true
    # -k: don't let unrelated sample tools (half_mt, dcraw_half, ...)
    # failing abort the whole build before unprocessed_raw gets built.
    make -k -j"$(nproc)" || true

    mkdir -p bin
    if [ ! -f bin/unprocessed_raw ]; then
        "${cxx}" -DLIBRAW_NOTHREADS -O3 -I. -w \
            -static-libgcc -static-libstdc++ \
            -o bin/unprocessed_raw samples/unprocessed_raw.cpp \
            -L./lib -lraw -lm
    fi

    if [ ! -f bin/unprocessed_raw ]; then
        echo "ERROR: bin/unprocessed_raw was not produced for ${arch}." >&2
        popd >/dev/null
        return 1
    fi

    mkdir -p "${OUTDIR}/${arch}"
    cp bin/unprocessed_raw "${OUTDIR}/${arch}/${LINUX_BINNAME}"

    popd >/dev/null

    echo "==> Result for ${arch}:"
    file "${OUTDIR}/${arch}/${LINUX_BINNAME}"
}

# ---------------------------------------------------------------------------
# 3. Build one Windows (mingw) target using the repo's own Makefile.mingw.
#    $1 = arch label ("win64" / "win32")
#    $2 = CXX cross compiler (e.g. x86_64-w64-mingw32-g++)
#    $3 = CC  cross compiler (e.g. x86_64-w64-mingw32-gcc)
# ---------------------------------------------------------------------------
build_windows_target() {
    local arch="$1" cxx="$2" cc="$3"
    local src_dir="${WORKDIR}/${arch}"

    echo "############################################################"
    echo "## Building Windows ${arch} (mingw)"
    echo "############################################################"

    rm -rf "${src_dir}"
    git clone --depth 1 "${REPO_URL}" "${src_dir}"
    cp "${SRC_CPP}" "${src_dir}/samples/unprocessed_raw.cpp"

    pushd "${src_dir}" >/dev/null

    make clean -f Makefile.mingw || true
    # CFLAGS override on the command line is equivalent to editing the
    # third line of Makefile.mingw by hand (make command-line variables
    # take priority over a plain "=" assignment inside the Makefile) --
    # this adds -static-libgcc -static-libstdc++ so the .exe doesn't need
    # a matching mingw runtime DLL alongside it.
    make -f Makefile.mingw \
        CXX="${cxx}" \
        CC="${cc}" \
        CFLAGS="-O3 -I. -w -static-libgcc -static-libstdc++"

    if [ ! -f bin/unprocessed_raw.exe ]; then
        echo "ERROR: bin/unprocessed_raw.exe was not produced for ${arch}." >&2
        popd >/dev/null
        return 1
    fi

    mkdir -p "${OUTDIR}/${arch}"
    cp bin/unprocessed_raw.exe "${OUTDIR}/${arch}/unprocessed_raw.exe"

    popd >/dev/null

    echo "==> Result for ${arch}:"
    file "${OUTDIR}/${arch}/unprocessed_raw.exe"
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
if [ ! -f "${SRC_CPP}" ]; then
    echo "ERROR: ${SRC_CPP} not found. Place your fixed unprocessed_raw.cpp" \
         "next to this script (or edit SRC_CPP)." >&2
    exit 1
fi

if ! command -v aarch64-linux-gnu-g++ >/dev/null 2>&1 || \
   ! command -v arm-linux-gnueabihf-g++ >/dev/null 2>&1 || \
   ! command -v x86_64-w64-mingw32-g++ >/dev/null 2>&1 || \
   ! command -v i686-w64-mingw32-g++ >/dev/null 2>&1 || \
   ! command -v i686-linux-gnu-g++ >/dev/null 2>&1; then
    install_toolchains
fi

mkdir -p "${WORKDIR}" "${OUTDIR}"

declare -A results

build_linux_target "linux-x86_64" "" "gcc" "g++" \
    && results[linux-x86_64]=ok || results[linux-x86_64]=FAILED

build_linux_target "linux-x86_32" "i686-linux-gnu" "i686-linux-gnu-gcc" "i686-linux-gnu-g++" \
    && results[linux-x86_32]=ok || results[linux-x86_32]=FAILED

build_linux_target "aarch64" "aarch64-linux-gnu" \
    "aarch64-linux-gnu-gcc" "aarch64-linux-gnu-g++" \
    && results[aarch64]=ok || results[aarch64]=FAILED

build_linux_target "armhf" "arm-linux-gnueabihf" \
    "arm-linux-gnueabihf-gcc" "arm-linux-gnueabihf-g++" \
    && results[armhf]=ok || results[armhf]=FAILED

build_windows_target "win64" "x86_64-w64-mingw32-g++" "x86_64-w64-mingw32-gcc" \
    && results[win64]=ok || results[win64]=FAILED

build_windows_target "win32" "i686-w64-mingw32-g++" "i686-w64-mingw32-gcc" \
    && results[win32]=ok || results[win32]=FAILED

echo
echo "Done. Results:"
for arch in linux-x86_64 linux-x86_32 aarch64 armhf win64 win32; do
    echo "  ${arch}: ${results[$arch]}"
done
echo
echo "Binaries (where successful):"
echo "  ${OUTDIR}/linux-x86_64/${LINUX_BINNAME}"
echo "  ${OUTDIR}/linux-x86_32/${LINUX_BINNAME}"
echo "  ${OUTDIR}/aarch64/${LINUX_BINNAME}"
echo "  ${OUTDIR}/armhf/${LINUX_BINNAME}"
echo "  ${OUTDIR}/win64/unprocessed_raw.exe"
echo "  ${OUTDIR}/win32/unprocessed_raw.exe"
