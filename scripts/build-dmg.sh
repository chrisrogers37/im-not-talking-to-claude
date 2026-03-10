#!/bin/bash
set -euo pipefail

# INTTC build script — adapted from Benzo
# Usage: ./scripts/build-dmg.sh

cd "$(dirname "$0")/.."

PROJECT="INTTC/INTTC.xcodeproj"
SCHEME="INTTC"
ARCHIVE_PATH="INTTC/build/INTTC.xcarchive"
EXPORT_PATH="INTTC/build/export"
EXPORT_OPTIONS="INTTC/ExportOptions.plist"

# Read version from project
VERSION=$(xcodebuild -project "$PROJECT" -showBuildSettings 2>/dev/null | grep MARKETING_VERSION | head -1 | awk '{print $3}')
DMG_NAME="INTTC-v${VERSION}.dmg"

echo "Building INTTC v${VERSION}..."

# Archive
echo "Step 1: Creating archive..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release \
    CODE_SIGN_IDENTITY="Developer ID Application" \
    DEVELOPMENT_TEAM="${APPLE_TEAM_ID:-}"

# Export
echo "Step 2: Exporting..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS"

# Notarize
echo "Step 3: Notarizing..."
xcrun notarytool submit "${EXPORT_PATH}/INTTC.app" \
    --apple-id "${APPLE_ID}" \
    --team-id "${APPLE_TEAM_ID}" \
    --password "${APP_PASSWORD}" \
    --wait

# Staple
echo "Step 4: Stapling..."
xcrun stapler staple "${EXPORT_PATH}/INTTC.app"

# Create DMG
echo "Step 5: Creating DMG..."
hdiutil create -volname "INTTC" \
    -srcfolder "${EXPORT_PATH}/INTTC.app" \
    -ov -format UDZO \
    "INTTC/build/${DMG_NAME}"

# Notarize DMG
xcrun notarytool submit "INTTC/build/${DMG_NAME}" \
    --apple-id "${APPLE_ID}" \
    --team-id "${APPLE_TEAM_ID}" \
    --password "${APP_PASSWORD}" \
    --wait

xcrun stapler staple "INTTC/build/${DMG_NAME}"

# Checksum
SHA=$(shasum -a 256 "INTTC/build/${DMG_NAME}" | awk '{print $1}')

echo ""
echo "=== Build Complete ==="
echo "DMG: INTTC/build/${DMG_NAME}"
echo "SHA-256: ${SHA}"
echo ""
echo "To create a GitHub release:"
echo "  gh release create v${VERSION} INTTC/build/${DMG_NAME} --title \"INTTC v${VERSION}\" --notes \"...\""
