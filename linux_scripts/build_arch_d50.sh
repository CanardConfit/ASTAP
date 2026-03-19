#!/bin/bash
# --- GLOBAL CONFIGURATION ---
PKG_NAME="D50"
PKG_VER=1.0
PKG_REL="1"
# Get the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# Ensure we start in the script directory
cd "$SCRIPT_DIR" || exit
# ==========================================
# PART 1: AMD64 (x86_64)
# ==========================================
echo "Building D50 package..."
# 1. Setup temporary workspace
BUILD_DIR=./arch_d50

# Fix directory permissions
find "$BUILD_DIR" -type d -exec chmod 755 {} \;

# 3. Generate .PKGINFO
cat <<EOF > "$BUILD_DIR/.PKGINFO"
pkgname = $PKG_NAME
pkgbase = $PKG_NAME
pkgver = $PKG_VER-$PKG_REL
pkgdesc = D50 star database
url = https://www.hnsky.org/astap.htm
builddate = $(date +%s)
packager = Anonymous <user@lubuntu>
size = $(du -sb "$BUILD_DIR" | awk '{print $1}')
arch = any
license = custom
EOF
# 4. Generate .MTREE and Compress
(
    cd "$BUILD_DIR"
    find . -mindepth 1 -not -path '*/.*' | \
        bsdtar -czf .MTREE --format=mtree \
        --options='!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link' -T -

    bsdtar --uid 0 --gid 0 -cf - .PKGINFO .MTREE opt/ | zstd -z -3 -T0 > "$SCRIPT_DIR/d50_star_database.pkg.tar.zst"
)

