#!/bin/bash

case "$1" in
    workspace-*) xdotool key super+$(echo "$1" | cut -d- -f2) ;;
    send-workspace-*) xdotool key super+shift+$(echo "$1" | cut -d- -f3) ;;
    close-window) xdotool key super+shift+c ;;
    split-window) xdotool key super+return ;;
    fullscreen) xdotool key super+f ;;
    toggle-float) xdotool key super+shift+space ;;
    focus-left) xdotool key super+h ;;
    focus-right) xdotool key super+l ;;
    focus-up) xdotool key super+k ;;
    focus-down) xdotool key super+j ;;
    move-left) xdotool key super+shift+h ;;
    move-right) xdotool key super+shift+l ;;
    move-up) xdotool key super+shift+k ;;
    move-down) xdotool key super+shift+j ;;
    layout-stack) xdotool key super+shift+s ;;
    layout-tab) xdotool key super+shift+t ;;
    layout-toggle) xdotool key super+space ;;
    quit-xmonad) xdotool key super+shift+q ;;
    *) echo "Unknown command: $1" ;;
esac
