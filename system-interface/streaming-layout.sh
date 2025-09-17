#!/bin/bash
# Streaming Layout Script - Programmatic 1:4:1 Layout Generation

echo "Launching streaming applications and creating programmatic layout..."

# Launch applications
obs &
steam &
discord &

# Wait for applications to start
sleep 3

# Get screen dimensions
SCREEN_WIDTH=$(gdbus call --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig --method org.gnome.Mutter.DisplayConfig.GetCurrentState | grep -o '"logical-monitors":\[{"x":0,"y":0,"scale":1,"monitor":0,"current-mode":0,"width":[0-9]*,"height":[0-9]*' | grep -o '"width":[0-9]*' | cut -d: -f2)
SCREEN_HEIGHT=$(gdbus call --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig --method org.gnome.Mutter.DisplayConfig.GetCurrentState | grep -o '"logical-monitors":\[{"x":0,"y":0,"scale":1,"monitor":0,"current-mode":0,"width":[0-9]*,"height":[0-9]*' | grep -o '"height":[0-9]*' | cut -d: -f2)

echo "Screen dimensions: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"

# Calculate 1:4:1 layout ratios
TOP_HEIGHT=$((SCREEN_HEIGHT / 6))        # 1/6 of screen height
CENTER_HEIGHT=$((SCREEN_HEIGHT * 4 / 6)) # 4/6 of screen height  
BOTTOM_HEIGHT=$((SCREEN_HEIGHT / 6))     # 1/6 of screen height

echo "Layout ratios: Top=${TOP_HEIGHT}px, Center=${CENTER_HEIGHT}px, Bottom=${BOTTOM_HEIGHT}px"

# Use GNOME Shell JavaScript API to programmatically tile windows
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "
const Main = imports.ui.main;
const Meta = imports.gi.Meta;

// Get all windows
const windows = global.get_window_actors().map(actor => actor.meta_window);

// Find our target windows
let obsWindow = null;
let steamWindow = null;
let discordWindow = null;

windows.forEach(window => {
  const wmClass = window.get_wm_class();
  if (wmClass && wmClass.toLowerCase().includes('obs')) {
    obsWindow = window;
  } else if (wmClass && wmClass.toLowerCase().includes('steam')) {
    steamWindow = window;
  } else if (wmClass && wmClass.toLowerCase().includes('discord')) {
    discordWindow = window;
  }
});

if (obsWindow) {
  // Position OBS at top (1/6 height)
  obsWindow.move_resize_frame(false, 0, 0, ${SCREEN_WIDTH}, ${TOP_HEIGHT});
  obsWindow.tile(Meta.TileMode.TILED);
  print('OBS positioned at top');
}

if (steamWindow) {
  // Position Steam in center (4/6 height)
  steamWindow.move_resize_frame(false, 0, ${TOP_HEIGHT}, ${SCREEN_WIDTH}, ${CENTER_HEIGHT});
  steamWindow.tile(Meta.TileMode.TILED);
  print('Steam positioned in center');
}

if (discordWindow) {
  // Position Discord at bottom (1/6 height)
  discordWindow.move_resize_frame(false, 0, ${TOP_HEIGHT + CENTER_HEIGHT}, ${SCREEN_WIDTH}, ${BOTTOM_HEIGHT});
  discordWindow.tile(Meta.TileMode.TILED);
  print('Discord positioned at bottom');
}

print('Programmatic 1:4:1 layout applied successfully');
"

echo "Programmatic layout applied! Windows should now be in 1:4:1 ratio."
