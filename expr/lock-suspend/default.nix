{ stdenv, bash, dbus_tools, gnused, systemd, lock }:

let script = ''
#!${bash}/bin/bash

# This filter gets all PrepareForSleep messages from logind
match="\
  type='signal',\
  sender='org.freedesktop.login1',\
  interface='org.freedesktop.login1.Manager',\
  member='PrepareForSleep',\
  path='/org/freedesktop/login1'\
"

# Watch the dbus for prepare for sleep messages
#
# The match makes sure that the only *broadcast* messages
# that we get are the PrepareForSleep events. However, we can
# still receive other messages if they are addressed directly
# to our connection. To get only broadcast messages, we check
# that the destination of the event is null. In that case,
# dbus-monitor prints `dest=(null destination)` for the event.
#
# Next, we are only interested in the PrepareForSleep(true) event,
# which is triggered before sleeping (PrepareForSleep(false) is triggered
# on wakeup). Thus, we grep for true.
coproc monitor {
  exec ${dbus_tools}/bin/dbus-monitor --system "\$match" > >(
    ${gnused}/bin/sed -une "/dest=(null destination)/{n;p}" |
    ${gnused}/bin/sed -une "/boolean true/p" )
}

# Now, wait till we receive the PrepareForSleep event
read -r  -u \''${monitor[0]}

# Kill our monitor process
kill \$monitor_PID

# Start the screen locker and tell it to re-run our script on unlock
exec ${lock}/bin/lock "$out/bin/lock-on-suspend"
'';

in stdenv.mkDerivation {
  name = "lock-on-suspend";
  buildCommand = ''
    mkdir -p $out/bin $out/libexec
    cat > $out/libexec/lock-on-suspend.action <<EOF
    ${script}
    EOF
    chmod +x $out/libexec/lock-on-suspend.action

    cat > $out/bin/lock-on-suspend <<EOF
    #!${bash}/bin/bash
    exec ${systemd}/bin/systemd-inhibit --what=sleep $out/libexec/lock-on-suspend.action
    EOF
    chmod +x $out/bin/lock-on-suspend
  '';
}
