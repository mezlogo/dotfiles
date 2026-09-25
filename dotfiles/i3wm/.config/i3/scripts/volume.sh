#!/usr/bin/env bash

send_pkill() {
  pkill -RTMIN+1 i3blocks
}

read_value() {
  wpctl get-volume @DEFAULT_SINK@ | sed -e 's/.* //'
}

show_progress() {
  value="$(read_value)"
  notify-send "volume: $value" -h string:x-canonical-private-synchronous:my-notification
}

command="$1"

case "$command" in
  up | down)
    step="5%+"
    if [[ "$command" == "down" ]]; then
      step="5%-"
    fi
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$step"
    send_pkill
    show_progress
    ;;
  mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  get-level) read_value ;;
  *) echo "unknown command: [$command]" ;;
esac
