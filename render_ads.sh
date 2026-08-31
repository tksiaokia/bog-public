#!/usr/bin/env bash
# Render the Facebook ad creatives to marketing/ at 2x via headless Chrome.
#
#   bash render_ads.sh            # render the current (soft-launch) set
#   bash render_ads.sh prereg     # re-render the old pre-register set
#
# 2x device scale matches the existing marketing/ PNGs (a 1080x1080 creative -> 2160x2160).
# --virtual-time-budget gives the Google Fonts request (Cinzel) time to land before capture;
# without it the title falls back to a system serif.
set -euo pipefail
cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || { echo "Chrome not found at $CHROME"; exit 1; }
mkdir -p marketing

shot() {  # shot <html> <w> <h> <out>
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=2 --window-size="$2,$3" --virtual-time-budget=8000 \
    --screenshot="marketing/$4" "file://$PWD/$1" 2>/dev/null || true
  [ -s "marketing/$4" ] || { echo "FAILED: $4"; exit 1; }
  printf '  %-34s %s\n' "$4" "$(sips -g pixelWidth -g pixelHeight "marketing/$4" \
    | awk '/pixel/{printf "%s ", $2}')"
}

if [ "${1:-launch}" = "prereg" ]; then
  echo "Rendering PRE-REGISTER set (archive):"
  shot _ad_creative.html            1080 1080 bog_ad_square_en.png
  shot _ad_creative_story.html      1080 1920 bog_ad_story_en.png
  shot _ad_creative_landscape.html  1200  628 bog_ad_landscape_en.png
else
  echo "Rendering SOFT-LAUNCH set (Android / Google Play, English):"
  shot _ad_launch.html            1080 1080 bog_launch_square_en.png
  shot _ad_launch_story.html      1080 1920 bog_launch_story_en.png
  shot _ad_launch_landscape.html  1200  628 bog_launch_landscape_en.png
fi
echo "Done."
