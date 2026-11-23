# vim: set ft=just :
# gnome layer: only what reads or writes a GNOME interface (dconf/gsettings,
# GNOME Shell extensions, GNOME-integration helpers). Everything that works on
# any desktop lives in the linux layer. Every recipe carries [linux]
# (`just check` enforces it).

import "dconf.just"
import "extensions.just"
import "desktop.just"
