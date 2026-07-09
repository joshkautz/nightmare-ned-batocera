#!/bin/sh
# Patched 86Box Flatpak launcher wrapper.
# Install over the flatpak's bin/86Box.sh (keep a .orig backup).
# With no args (how Batocera's flatpak generator calls it), boot straight
# into the Nightmare Ned VM in fullscreen. Manual launches with args still work.
mkdir -p ${XDG_DATA_HOME}/86Box/roms
mkdir -p ${XDG_CONFIG_HOME}/86Box
if [ $# -eq 0 ]; then
  exec 86Box --vmpath "${XDG_DATA_HOME}/86Box/Virtual Machines/Nightmare Ned" --vmname "Nightmare Ned" --fullscreen
fi
exec 86Box "$@"
