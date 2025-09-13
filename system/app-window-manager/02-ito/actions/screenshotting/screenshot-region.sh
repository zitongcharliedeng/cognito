#!/bin/sh
# Screenshot region using grim+slurp
grim -g "$(slurp)" ~/screenshot-$(date +%Y%m%d-%H%M%S).png
