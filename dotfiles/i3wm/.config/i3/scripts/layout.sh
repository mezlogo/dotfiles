#!/usr/bin/env bash

send_pkill() {
  pkill -RTMIN+3 i3blocks
}

read_value() {
  xkb-switch -p
}

show_progress() {
  value="$(read_value)"
  notify-send -t 500 "layout: $value" -h string:x-canonical-private-synchronous:my-notification
}

command="$1"

case "$command" in
  next)
    xkb-switch --next
    send_pkill
    show_progress
    ;;
  get-layout) read_value ;;
  *) echo "unknown command: [$command]" ;;
esac
