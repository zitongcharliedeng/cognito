#!/bin/sh
# Manual eww startup for testing
eww daemon &
sleep 1
eww open bar
echo "Eww bar should now be visible at the top"

