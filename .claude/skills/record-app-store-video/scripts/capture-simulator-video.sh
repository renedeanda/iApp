#!/bin/zsh
set -euo pipefail

usage() {
  print -u2 "Usage: $0 <simulator-udid> <output.mov> [--codec h264|hevc] [--yes]"
}

[[ $# -ge 2 ]] || { usage; exit 64; }

udid="$1"
output="$2"
shift 2
codec="h264"
confirmed=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codec)
      [[ $# -ge 2 ]] || { usage; exit 64; }
      codec="$2"
      shift 2
      ;;
    --yes)
      confirmed=1
      shift
      ;;
    *)
      usage
      exit 64
      ;;
  esac
done

[[ "$codec" == "h264" || "$codec" == "hevc" ]] || {
  print -u2 "Unsupported codec: $codec"
  exit 64
}

xcrun simctl list devices | rg -q "$udid.*Booted" || {
  print -u2 "Simulator is not booted: $udid"
  exit 69
}

output_dir="${output:h}"
mkdir -p "$output_dir"

if [[ -e "$output" ]]; then
  print -u2 "Refusing to overwrite existing video: $output"
  exit 73
fi

if [[ $confirmed -ne 1 ]]; then
  print "Ready to record $udid to $output. Press Return to begin or Control-C to cancel."
  read -r
fi

print "Recording. Interact with Simulator, then press Control-C here to finish."
xcrun simctl io "$udid" recordVideo --codec="$codec" "$output"
