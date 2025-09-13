#!/bin/sh
# Screenshot window using grim+slurp
grim -g "$(slurp -o)" ~/screenshot-$(date +%Y%m%d-%H%M%S).png
