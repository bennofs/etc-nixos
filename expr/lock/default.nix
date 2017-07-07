{ bash, writeScriptBin, i3lock, xprop, xdotool }:

writeScriptBin "lock" ''
  #!${bash}/bin/bash
  ${xprop}/bin/xprop -root -f _SCREEN_LOCKED 8b -set _SCREEN_LOCKED True
  ${xdotool}/bin/xdotool key "Control+Alt+Super+l"
  cmd=''${1:-true}
  shift
  ((
    ${i3lock}/bin/i3lock --nofork --top-margin 22 -i "/data/pics/lockscreen.png"
    ${xprop}/bin/xprop -root -f _SCREEN_LOCKED 8b -set _SCREEN_LOCKED False
    ${xdotool}/bin/xdotool key "Control+Alt+Super+l"

    exec "$cmd" "$@" &> /dev/null
  ) & disown) | (
    while read i; do
      if [ "$i" = "ready" ]; then
        exit 0
      fi
    done
    echo "Error: no ready from screen locker" >&2
    exit 1
  )
''
