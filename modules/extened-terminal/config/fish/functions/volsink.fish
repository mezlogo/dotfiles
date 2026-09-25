function volsink --description 'set default volume sink'
    set -l SINK $(wpctl status | sed -n '/Sinks:/,/Sources:/p' | string replace -a '├' '' | string replace -a '─' '' | string replace -a '│' '' | string replace -a '└' '' | string match -r '.*\[vol:.*' | string replace -r '\s*\[vol:.*$' '' | string replace -r '^\s*(\d+)\.' '$1\t' | string replace -r '.*?\\*.*?(\\d+).*?(\\w.*$)' '$1 $2 *' | string replace -r '\s+' ' ' | fzf)
    if test -n "$SINK"
        set -l SINK_ID $(echo "$SINK" | string replace -r '(\d+).*' '$1')
        wpctl set-default "$SINK_ID"
    end
end
