#!/bin/bash
# --- GLOBAL CONFIGURATION ---
PKG_NAME="astap"
PKG_VER=$(date +%Y.%m.%d)
PKG_REL="1"
# Get the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# Ensure we start in the script directory
cd "$SCRIPT_DIR" || exit
# ==========================================
# PART 1: AMD64 (x86_64)
# ==========================================
echo "Building AMD64 package..."
# 1. Setup temporary workspace
BUILD_DIR=./arch_amd64
mkdir -p "$BUILD_DIR/opt/astap"
mkdir -p "$BUILD_DIR/usr/share/applications"
# 2. Copy files - using * ensures binaries without extensions are caught
cp -r ./astap_amd64/opt/astap/* "$BUILD_DIR/opt/astap/"
cp ./astap_amd64/usr/share/applications/ASTAP.desktop "$BUILD_DIR/usr/share/applications/"
# Fix directory permissions
find "$BUILD_DIR" -type d -exec chmod 755 {} \;

# 3. Generate .PKGINFO
cat <<EOF > "$BUILD_DIR/.PKGINFO"
pkgname = $PKG_NAME
pkgbase = $PKG_NAME
pkgver = $PKG_VER-$PKG_REL
pkgdesc = ASTAP program
url = https://www.hnsky.org/astap.htm
builddate = $(date +%s)
packager = Anonymous <user@lubuntu>
size = $(du -sb "$BUILD_DIR" | awk '{print $1}')
arch = x86_64
license = MPL-2.0
EOF
# 4. Generate .MTREE and Compress
(
    cd "$BUILD_DIR"
    find . -mindepth 1 -not -path '*/.*' | \
        bsdtar -czf .MTREE --format=mtree \
        --options='!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link' -T -

    bsdtar --uid 0 --gid 0 -cf - .PKGINFO .MTREE opt/ usr/ | zstd -z -3 -T0 > "$SCRIPT_DIR/astap_amd64.pkg.tar.zst"
)


PKG_NAME="astap"
PKG_VER=$(date +%Y.%m.%d)
PKG_REL="1"
# Get the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
# Ensure we start in the script directory
cd "$SCRIPT_DIR" || exit
# ==========================================
# PART 1B: AMD64 (x86_64) GTK3
# ==========================================
echo "Building AMD64 package..."
# 1. Setup temporary workspace
BUILD_DIR=./arch_amd64_gtk3
mkdir -p "$BUILD_DIR/opt/astap"
mkdir -p "$BUILD_DIR/usr/share/applications"
# 2. Copy files - using * ensures binaries without extensions are caught
cp -r ./astap_amd64_gtk3/opt/astap/* "$BUILD_DIR/opt/astap/"
cp ./astap_amd64_gtk3/usr/share/applications/ASTAP.desktop "$BUILD_DIR/usr/share/applications/"
# Fix directory permissions
find "$BUILD_DIR" -type d -exec chmod 755 {} \;

# 3. Generate .PKGINFO
cat <<EOF > "$BUILD_DIR/.PKGINFO"
pkgname = $PKG_NAME
pkgbase = $PKG_NAME
pkgver = $PKG_VER-$PKG_REL
pkgdesc = ASTAP program
url = https://www.hnsky.org/astap.htm
builddate = $(date +%s)
packager = Anonymous <user@lubuntu>
size = $(du -sb "$BUILD_DIR" | awk '{print $1}')
arch = x86_64
license = MPL-2.0
EOF
# 4. Generate .MTREE and Compress
(
    cd "$BUILD_DIR"
    find . -mindepth 1 -not -path '*/.*' | \
        bsdtar -czf .MTREE --format=mtree \
        --options='!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link' -T -

    bsdtar --uid 0 --gid 0 -cf - .PKGINFO .MTREE opt/ usr/ | zstd -z -3 -T0 > "$SCRIPT_DIR/astap_amd64_gtk3.pkg.tar.zst"
)






# ==========================================
# PART 2: AARCH64 (ARM64)
# ==========================================
echo "Building AARCH64 package..."
# 1. Setup temporary workspace
BUILD_DIR=./arch_aarch64
# 2. Copy files
cp -r ./astap_aarch64/opt/astap/* "$BUILD_DIR/opt/astap/"
cp ./astap_aarch64/usr/share/applications/ASTAP.desktop "$BUILD_DIR/usr/share/applications/"
# Fix directory permissions
find "$BUILD_DIR" -type d -exec chmod 755 {} \;
# 3. Generate .PKGINFO
cat <<EOF > "$BUILD_DIR/.PKGINFO"
pkgname = $PKG_NAME
pkgbase = $PKG_NAME
pkgver = $PKG_VER-$PKG_REL
pkgdesc = ASTAP program
url = https://www.hnsky.org/astap.htm
builddate = $(date +%s)
packager = Anonymous <user@lubuntu>
size = $(du -sb "$BUILD_DIR" | awk '{print $1}')
arch = aarch64
license = MPL-2.0
EOF
# 4. Generate .MTREE and Compress
(
    cd "$BUILD_DIR"
    find . -mindepth 1 -not -path '*/.*' | \
        bsdtar -czf .MTREE --format=mtree \
        --options='!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link' -T -

    bsdtar --uid 0 --gid 0 -cf - .PKGINFO .MTREE opt/ usr/ | zstd -z -3 -T0 > "$SCRIPT_DIR/astap_aarch64.pkg.tar.zst"
)
echo "Done! Packages created in $SCRIPT_DIR"




# ==========================================
# PART 2B: AARCH64 (ARM64) GTK3
# ==========================================
echo "Building AARCH64 package..."
# 1. Setup temporary workspace
BUILD_DIR=./arch_aarch64_gtk3
# 2. Copy files
cp -r ./astap_aarch64_gtk3/opt/astap/* "$BUILD_DIR/opt/astap/"
cp ./astap_aarch64_gtk3/usr/share/applications/ASTAP.desktop "$BUILD_DIR/usr/share/applications/"
# Fix directory permissions
find "$BUILD_DIR" -type d -exec chmod 755 {} \;
# 3. Generate .PKGINFO
cat <<EOF > "$BUILD_DIR/.PKGINFO"
pkgname = $PKG_NAME
pkgbase = $PKG_NAME
pkgver = $PKG_VER-$PKG_REL
pkgdesc = ASTAP program
url = https://www.hnsky.org/astap.htm
builddate = $(date +%s)
packager = Anonymous <user@lubuntu>
size = $(du -sb "$BUILD_DIR" | awk '{print $1}')
arch = aarch64
license = MPL-2.0
EOF
# 4. Generate .MTREE and Compress
(
    cd "$BUILD_DIR"
    find . -mindepth 1 -not -path '*/.*' | \
        bsdtar -czf .MTREE --format=mtree \
        --options='!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link' -T -

    bsdtar --uid 0 --gid 0 -cf - .PKGINFO .MTREE opt/ usr/ | zstd -z -3 -T0 > "$SCRIPT_DIR/astap_aarch64.pkg.tar.zst"
)
echo "Done! Packages created in $SCRIPT_DIR"
