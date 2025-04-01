#!/bin/bash

# ==============================================
# Super Simple Library Installer Builder
# ==============================================

# Output filename
OUTPUT_PKG="openssl_libraries.pkg"

# Temp working directory (will be deleted after)
TMP_DIR=$(mktemp -d)

# Set up directory structure
mkdir -p "${TMP_DIR}/root/usr/local/lib"
mkdir -p "${TMP_DIR}/scripts"

# Copy the libraries
cp /usr/local/lib/libssl.1.1.dylib "${TMP_DIR}/root/usr/local/lib/"
cp /usr/local/lib/libcrypto.1.1.dylib "${TMP_DIR}/root/usr/local/lib/"

# Create a postinstall script to fix permissions
cat > "${TMP_DIR}/scripts/postinstall" <<EOF
#!/bin/sh
chmod 755 /usr/local/lib/libssl.1.1.dylib /usr/local/lib/libcrypto.1.1.dylib
EOF
chmod +x "${TMP_DIR}/scripts/postinstall"

# Build the package
echo "Building package..."
pkgbuild \
  --root "${TMP_DIR}/root" \
  --scripts "${TMP_DIR}/scripts" \
  --identifier "OPENSSL" \
  --version "1.1" \
  --install-location "/" \
  "${OUTPUT_PKG}"

# Clean up
rm -rf "${TMP_DIR}"

echo "Done! Installer created at: ${OUTPUT_PKG}"