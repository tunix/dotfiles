# vim: set ft=just :
# Common recipes: available on every host. These must never depend on a
# recipe from an OS-specific layer — on the other OS the whole justfile
# would fail to parse (`just check` enforces this).
#
# Variables provided by the host file (hosts/<name>.just):
#   repo_root  absolute path of this checkout
#   layers     active layers, in apply order
#   host_file  absolute path of the host file itself

import "core.just"
import "brew.just"
import "shell.just"
import "lazyvim.just"
import "ssh.just"
