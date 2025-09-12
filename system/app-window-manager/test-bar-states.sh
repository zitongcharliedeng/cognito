#!/bin/sh
#
# Test script to demonstrate all status bar state combinations
# Shows the interaction between baseBarMode and isBarForcedExpanded

echo "=== Status Bar State Test ==="
echo "Testing all combinations of baseBarMode and isBarForcedExpanded"
echo

# Function to show current state
show_state() {
    echo "Current state: baseBarMode=$(eww get baseBarMode 2>/dev/null || echo 'unknown'), isBarForcedExpanded=$(eww get isBarForcedExpanded 2>/dev/null || echo 'unknown')"
}

echo "1. Normal base mode, no forced expansion (default state)"
set-base-bar-mode normal
set-bar-forced-expansion false
show_state
echo "Expected: Normal bar displayed"
echo
sleep 2

echo "2. Normal base mode, with forced expansion"
set-base-bar-mode normal  
set-bar-forced-expansion true
show_state
echo "Expected: Expanded bar displayed (overrides normal)"
echo
sleep 2

echo "3. Collapsed base mode, no forced expansion"
set-base-bar-mode collapsed
set-bar-forced-expansion false
show_state
echo "Expected: Collapsed bar (hidden/minimal)"
echo
sleep 2

echo "4. Collapsed base mode, with forced expansion"
set-base-bar-mode collapsed
set-bar-forced-expansion true
show_state
echo "Expected: Expanded bar displayed (overrides collapsed)"
echo
sleep 2

echo "5. Return to normal state"
set-base-bar-mode normal
set-bar-forced-expansion false
show_state
echo "Expected: Normal bar displayed"
echo

echo "=== Test Complete ==="
echo "Logic: isBarForcedExpanded takes precedence over baseBarMode"
echo "  - true  -> barContainerExpanded"
echo "  - false -> baseBarMode (normal -> barContainerNormal, collapsed -> barContainerCollapsed)"