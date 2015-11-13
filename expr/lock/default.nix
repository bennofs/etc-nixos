{ bash, writeScriptBin, i3lock, xprop, xdotool }:

writeScriptBin "lock" ''
  #!${bash}/bin/bash
  ${xprop}/bin/xprop -root -f _SCREEN_LOCKED 8b -set _SCREEN_LOCKED True
  ${xdotool}/bin/xdotool key "Control+Alt+Super+l"
  cmd=''${1:-true}
  shift
  exec 3< <(
    ${i3lock}/bin/i3lock --nofork --top-margin 22 -i ${/data/pics/lockscreen.png}
    ${xprop}/bin/xprop -root -f _SCREEN_LOCKED 8b -set _SCREEN_LOCKED False
    ${xdotool}/bin/xdotool key "Control+Alt+Super+l"

    exec "$cmd" "$@"
  )
  read i <&3
''
