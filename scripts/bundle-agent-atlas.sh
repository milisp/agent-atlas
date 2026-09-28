#!/bin/bash
# Assemble Agent Atlas.app straight from the SwiftPM release build.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> building release binaries"
cargo build --release
# SwiftPM does not track the Rust staticlib, so drop a stale executable to force
# a relink against the fresh one (same guard as the Makefile's bundle target).
if [ target/release/libtb_core_ffi.a -nt .build/release/Syrtis ]; then
  rm -f .build/release/Syrtis
fi
swift build -c release

destination="dist/Agent Atlas.app"
echo "==> assembling $destination"
rm -rf "$destination"
mkdir -p dist
touch dist/.metadata_never_index
mkdir -p "$destination/Contents/MacOS" "$destination/Contents/Resources" "$destination/Contents/Frameworks"

cp .build/release/Syrtis "$destination/Contents/MacOS/AgentAtlas"
# The SwiftPM resource bundle keeps its target-derived name; the app looks it
# up by that name.
cp -R .build/release/Syrtis_Syrtis.bundle "$destination/Contents/Resources/"
cp -R Sources/Syrtis/Resources/Localizations/*.lproj "$destination/Contents/Resources/"
# The executable links Sparkle, so the framework must ship even though Agent
# Atlas sets no update feed.
cp -R "$(scripts/build-sparkle.sh)" "$destination/Contents/Frameworks/"

icon_info="$(mktemp -t agent-atlas-icon-info).plist"
trap 'rm -f "$icon_info"' EXIT
xcrun actool \
  --compile "$destination/Contents/Resources" \
  --platform macosx \
  --minimum-deployment-target 14.0 \
  --target-device mac \
  --app-icon AgentAtlasAppIcon \
  --output-partial-info-plist "$icon_info" \
  assets/AgentAtlasAssets.xcassets >/dev/null

python3 - "$destination/Contents/Info.plist" "$icon_info" <<'PY'
import plistlib
import sys

path, icon_info_path = sys.argv[1:]
info = {
    "CFBundleExecutable": "AgentAtlas",
    "CFBundleIdentifier": "dev.milisp.agent-atlas",
    "CFBundleName": "Agent Atlas",
    "CFBundleDisplayName": "Agent Atlas",
    "CFBundlePackageType": "APPL",
    "CFBundleShortVersionString": "0.1.0",
    "CFBundleVersion": "1",
    "CFBundleDevelopmentRegion": "en",
    "CFBundleLocalizations": ["en", "zh-Hans", "zh-Hant"],
    "LSMinimumSystemVersion": "14.0",
    "NSHumanReadableCopyright": "MIT License",
    "AgentAtlasStandalone": True,
}
with open(icon_info_path, "rb") as source:
    info.update(plistlib.load(source))
with open(path, "wb") as target:
    plistlib.dump(info, target)
PY

echo "==> ad-hoc codesign"
codesign --force --deep --sign - "$destination"
echo "Packaged $destination"
