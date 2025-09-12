# Widget Overlay State Machine Documentation


OMNIWIDGETS = TOGGLE OMNIBAR + STATUS BAR WHICH DROPS DOWN TO REVEAL MORE INTERACTABLES WHEN THE OMNIBAR IS VISIBLE. PRIMARY ACTION INTERFACE FOR A USER, LANGAUGE BASED AND REQUIRES ONLY ONE MEMORISATION -> THE BUTTON TO OPEN THE OMNI-VIEW (WHICH OPENS THE OMNIBAR AND EXPANDS STATUS BAR)

TODO clarify omnibar design.

## Overview
Pure state machine with memory + override for managing widget overlay states without side effects.

## State Machine Design for this...

### Core States
- **baseBarMode** = "collapsed" | "normal"
  - Memory of the "true" state (fullscreen forces collapsed, leaving fullscreen restores normal, etc.)
- **isBarForcedExpanded** = true | false
  - Temporary override (omnibar, hover, etc.)
  - e.g. when omnibar activated in fullscreen show it, but when omnibar disappear we still need to go back to the base fullscreen collapsed bar state

### State Logic
The state machine operates on two independent variables:
1. **Base state** - Persistent memory of what mode should be active
2. **Override state** - Temporary forced expansion that doesn't affect base state

### State Resolution Priority
```
Final State = isBarForcedExpanded ? "expanded" : baseBarMode
```

### State Transitions

#### Base State Transitions
- **Normal → Collapsed**: When fullscreen app detected
- **Collapsed → Normal**: When no fullscreen apps detected
- **Memory preserved**: Base state is never lost during overrides

#### Override State Transitions  
- **Any State → Expanded**: Temporary override (omnibar activation, hover, etc.)
- **Expanded → Base State**: Override removed, return to base state
- **No side effects**: Override never modifies base state

### Atomic State Management
- Single source of truth: `_sync-current-workspace-fullscreen-state` for **baseBarMode** = "collapsed" | "normal"
- All state changes flow through atomic action scripts
- State detection is environment-aware (workspace fullscreen detection)
- State application is implementation-agnostic

## State Machine Benefits
1. **Predictable**: Always returns to correct base state after overrides
2. **Side-effect free**: Overrides don't corrupt base state memory  
3. **Atomic**: All state changes are centralized and consistent
4. **Testable**: Pure state logic separated from implementation
5. **Maintainable**: State machine can be implemented with any widget system
