#!@pythonEnv@/bin/python3

import dbus
import os
import subprocess
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
from mpd import MPDClient

# Options for inhibiting. We want to inhibit sleeping so we can run the screen
# locker before that. Note that we need to use 'mode'='delay' instead of 'mode'='block',
# because 'block' will block the sleep action even before the 'PrepareForSleep' event
# is sent, but we depend on that event to know when we have to exit.
inhibit = { 
    "what" : "sleep", 
    "who" : "lock-on-suspend", 
    "why" : "Lock screen before suspending", 
    "mode" : "delay" 
}

DBusGMainLoop(set_as_default=True)

# Connect to logind via DBus
bus = dbus.SystemBus()
logind = bus.get_object('org.freedesktop.login1', '/org/freedesktop/login1')
logind.manager = dbus.Interface(logind, 'org.freedesktop.login1.Manager')

# Set ourself as an inhibitor. The inhibitor is active as long as the file descriptor
# that is returned is kept open.
fd = logind.manager.Inhibit(inhibit["what"], inhibit["who"], inhibit["why"], inhibit["mode"]).take()

# After registering, block till we are about to sleep. 
loop = GLib.MainLoop()
logind.manager.connect_to_signal("PrepareForSleep", lambda before: loop.quit() if before else None)
loop.run()

# Now, execute pre-sleep actions and then close the file descriptor to release the lock.
mpd = MPDClient()
mpd.connect("localhost", 6600)
mpd.stop()

subprocess.call(["@lock@/bin/lock", "@out@/bin/lock-on-suspend"])
os.close(fd)
