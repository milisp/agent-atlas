#!/bin/bash
# Package the full-window treemap as Agent Atlas, a separate local macOS app.
set -euo pipefail

cd "$(dirname "$0")/.."
make bundle

destination="dist/Agent Atlas.app"
ditto "dist/Syrtis.app" "$destination"
python3 - "$destination/Contents/Info.plist" <<'PY'
import plistlib
import sys

path = sys.argv[1]
with open(path, "rb") as source:
    info = plistlib.load(source)
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
