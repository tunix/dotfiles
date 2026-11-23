# vim: set ft=just :
# linux layer: every Linux host. OS-level, device-level and CLI state that any
# desktop needs; nothing here reads or writes a desktop-environment interface.
# Every recipe carries [linux] (`just check` enforces it).

import "path.just"
import "system.just"
import "apps.just"
