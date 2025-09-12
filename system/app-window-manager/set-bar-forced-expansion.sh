#!/bin/sh
#
# Control the status bar forced expansion override
# This temporarily overrides the baseBarMode when set to true
# 
# Usage: set-bar-forced-expansion <true|false>

if [ $# -ne 1 ]; then
    echo "Usage: set-bar-forced-expansion <true|false>"
    echo "  true  - Force expand the status bar (temporary override)"
    echo "  false - Remove forced expansion (return to baseBarMode)"
    exit 1
fi

EXPANSION="$1"

# Validate expansion parameter
case "$EXPANSION" in
    true|false)
        echo "Setting isBarForcedExpanded to: $EXPANSION"
        eww update isBarForcedExpanded="$EXPANSION"
        
        # Note: The hitbox management is handled by the baseBarMode state
        # When isBarForcedExpanded=true, the bar shows expanded but still
        # respects the current hitbox state (which follows baseBarMode)
        ;;
    *)
        echo "Error: Invalid expansion value '$EXPANSION'"
        echo "Valid values are: true, false"
        exit 1
        ;;
esac