#!/bin/bash
# Takes the store screenshots on one device (see
# integration_test/store_screenshots_test.dart).
#
#   tool/screenshots/take_screenshots.sh ios <simulator id> <track.m4a> <out dir>
#   tool/screenshots/take_screenshots.sh android <emulator id> <track.m4a> <out dir>
#
# Use a fresh simulator/emulator and a made-up track. Raw screenshots go to
# <out dir>; tool/screenshots/frame.swift adds the captions.
set -euo pipefail
platform=$1 device=$2 track=$3 out=$4
mkdir -p "$out"
cd "$(dirname "$0")/../.."

if [[ $platform == ios ]]; then
  # The simulator can read files on the Mac directly.
  music=$track
  xcrun simctl status_bar "$device" override --time 9:41 \
    --dataNetwork wifi --wifiBars 3 --cellularBars 4 \
    --batteryState charged --batteryLevel 100
  shoot() { xcrun simctl io "$device" screenshot "$out/$1.png" >/dev/null; }
else
  # Copied into the app's own files folder (run-as works for debug
  # builds), so it can read it without storage permissions. The app must
  # be installed once first (e.g. flutter run).
  package=app.saitoworks.rgroutineplanner
  name=demo-track.${track##*.}
  music=/data/user/0/$package/files/$name
  adb -s "$device" push "$track" /data/local/tmp/$name >/dev/null
  adb -s "$device" shell "run-as $package mkdir -p files && cat /data/local/tmp/$name | run-as $package sh -c 'cat > files/$name'"
  adb -s "$device" shell settings put global sysui_demo_allowed 1
  demo() { adb -s "$device" shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null; }
  demo enter
  demo clock -e hhmm 0941
  demo battery -e level 100 -e plugged false
  demo network -e wifi show -e level 4
  demo notifications -e visible false
  shoot() { adb -s "$device" exec-out screencap -p > "$out/$1.png"; }
fi

flutter test integration_test/store_screenshots_test.dart -d "$device" \
  --dart-define=SCREENSHOT_MUSIC="$music" 2>&1 |
  while IFS= read -r line; do
    echo "$line"
    if [[ $line =~ SCREENSHOT\ ([a-z0-9_]+) ]]; then
      shoot "${BASH_REMATCH[1]}"
      echo ">> captured ${BASH_REMATCH[1]}"
    fi
  done

if [[ $platform == ios ]]; then
  xcrun simctl status_bar "$device" clear
else
  adb -s "$device" shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null
fi
