{ bash, writeScriptBin, i3lock, xprop, xdotool }:

writeScriptBin "lock" ''
  #!${bash}/bin/bash
  ${xprop}/bin/xprop -root -f _SCREEN_LOCKED 8b -set _SCREEN_LOCKED True
  ${xdotool}/bin/xdotool key "Control+Alt+Super+l"
  exec 3< <(
    exec 4< <(${i3lock}/bin/i3lock --top-margin 22 -i /data/pics/lockscreen.png)
    read pid <&4
    echo $pid
    wait $pid
    ${xprop}/bin/xprop -root -f _SCREEN_LOCKED 8b -set _SCREEN_LOCKED False
    ${xdotool}/bin/xdotool key "Control+Alt+Super+l"
  )
  read i <&3
''
