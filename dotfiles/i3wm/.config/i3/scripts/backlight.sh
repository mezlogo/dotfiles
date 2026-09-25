#!/usr/bin/env bash

send_pkill() {
  pkill -RTMIN+2 i3blocks
}

read_value() {
  light -G
}

show_progress() {
  value="$(read_value)"
  notify-send "backlight: $value" -h string:x-canonical-private-synchronous:my-notification
}

command="$1"

case "$command" in
  up | down)
    step="-A"
    if [[ "$command" == "down" ]]; then
      step="-U"
    fi
    light "$step" 5
    send_pkill
    show_progress
    ;;
  get-level) read_value ;;
  *) echo "unknown command: [$command]" ;;
esac
