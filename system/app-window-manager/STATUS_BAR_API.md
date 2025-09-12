# Status Bar State Control API

The status bar uses a two-variable state system for maximum flexibility and control.

## State Variables

### `baseBarMode`
- **Values**: `"collapsed"` | `"normal"`
- **Purpose**: The "memory" state that persists across fullscreen transitions
- **Behavior**: 
  - `"normal"` - Show status bar with normal height (2.8% screen height)
  - `"collapsed"` - Hide/minimize status bar (no visible content)

### `isBarForcedExpanded`  
- **Values**: `true` | `false`
- **Purpose**: Temporary override for expanded display
- **Behavior**:
  - `true` - Force show expanded status bar (25% screen height) regardless of baseBarMode
  - `false` - Use baseBarMode to determine display

## State Priority Logic

The display logic follows this hierarchy:
```
if (isBarForcedExpanded == true)
    → Show barContainerExpanded (25% height)
else if (baseBarMode == "normal") 
    → Show barContainerNormal (2.8% height)
else 
    → Show barContainerCollapsed (hidden)
```

## Available Commands

### `set-base-bar-mode <collapsed|normal>`
Set the persistent base mode for the status bar.

**Examples:**
```bash
set-base-bar-mode normal     # Show status bar normally
set-base-bar-mode collapsed  # Hide status bar
```

### `set-bar-forced-expansion <true|false>`
Control the temporary expansion override.

**Examples:**
```bash
set-bar-forced-expansion true   # Force expand (overrides base mode)
set-bar-forced-expansion false  # Remove override (return to base mode)
```

### `_sync-current-workspace-fullscreen-state`
Internal helper that automatically sets `baseBarMode` based on fullscreen state:
- Fullscreen windows detected → `baseBarMode="collapsed"`
- No fullscreen windows → `baseBarMode="normal"`

## Usage Scenarios

### Scenario 1: Omnibar Activation
When opening the omnibar in fullscreen mode:
```bash
# During omnibar open
set-bar-forced-expansion true   # Show expanded bar temporarily

# During omnibar close  
set-bar-forced-expansion false  # Return to collapsed (fullscreen) state
```

### Scenario 2: Manual Bar Control
```bash
# Hide bar completely
set-base-bar-mode collapsed

# Show bar normally
set-base-bar-mode normal

# Temporarily expand current state
set-bar-forced-expansion true
```

### Scenario 3: Fullscreen Integration
The system automatically manages `baseBarMode` through fullscreen detection, but you can override:
```bash
# Override automatic fullscreen behavior
set-base-bar-mode normal  # Keep bar visible even in fullscreen
```

## Testing

Run `test-bar-states.sh` to see all state combinations in action.

## Integration Notes

- The eww hitbox window (`dropdown_status_bar_hitbox_normal`) controls space reservation
- The eww appearance window (`dropdown_status_bar_appearance`) handles visual rendering  
- State changes are immediate via `eww update` commands
- All state variables are reactive - widgets re-render automatically when changed