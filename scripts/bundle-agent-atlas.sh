#!/bin/bash
# Package the full-window treemap as Agent Atlas, a separate local macOS app.
set -euo pipefail

cd "$(dirname "$0")/.."
make bundle

destination="dist/Agent Atlas.app"
ditto "dist/Syrtis.app" "$destination"
icon_info="/private/tmp/agent-atlas-icon-info-$$.plist"
xcrun actool \
  --compile "$destination/Contents/Resources" \
  --platform macosx \
  --minimum-deployment-target 14.0 \
  --target-device mac \
  --app-icon AgentAtlasAppIcon \
  --output-partial-info-plist "$icon_info" \
  assets/AgentAtlasAssets.xcassets
rm -f "$destination/Contents/Resources/icon.icns"
python3 - "$destination/Contents/Info.plist" "$icon_info" <<'PY'
import plistlib
import sys

path, icon_info_path = sys.argv[1:]
with open(path, "rb") as source:
    info = plistlib.load(source)
with open(icon_info_path, "rb") as source:
    info.update(plistlib.load(source))
info["CFBundleIdentifier"] = "dev.milisp.agent-atlas"
info["CFBundleName"] = "Agent Atlas"
info["CFBundleDisplayName"] = "Agent Atlas"
info["AgentAtlasStandalone"] = True
info["LSUIElement"] = False
info.pop("NSLocalNetworkUsageDescription", None)
info.pop("SUFeedURL", None)
info.pop("SUPublicEDKey", None)
with open(path, "wb") as target:
    plistlib.dump(info, target)
PY
codesign --force --deep --sign - "$destination"
echo "Packaged $destination"
