#!/bin/sh
# Eww open wrapper with proper environment
export EWW_CONFIG_DIR=/etc/eww
exec eww "$@"
