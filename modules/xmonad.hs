-- Cognito OS XMonad Configuration
-- Migrated from Awesome WM for better NixOS integration
-- Zero keyboard shortcuts - all actions via rofi omnibar

import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.Spacing
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Util.SpawnOnce
import qualified XMonad.StackSet as W
import XMonad.Actions.CycleWS
import XMonad.Actions.WindowGo
import qualified Data.Map as M
import XMonad.Hooks.EwmhDesktops

-- Main configuration
main :: IO ()
main = xmonad $ ewmh $ docks def
  { modMask = mod4Mask  -- Use Super key as mod
  , terminal = "kitty"
  , borderWidth = 2
  , normalBorderColor = "#2d3748"
  , focusedBorderColor = "#4299e1"
  , layoutHook = myLayout
  , manageHook = myManageHook
  , startupHook = myStartupHook
  , logHook = dynamicLogWithPP myPP
  , mouseBindings = myMouseBindings
  , workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]  -- Explicitly define 10 workspaces (1-10)
  } `additionalKeysP` myKeys

-- Layout configuration
myLayout = avoidStruts $ spacing 4 $ tiled ||| Mirror tiled ||| Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    delta = 3/100
    ratio = 1/2

-- Manage hook
myManageHook = composeAll
  [ className =? "firefox" --> doShift "1"
  , className =? "thunar" --> doShift "1"
  , className =? "kitty" --> doShift "1"
  , className =? "gnome-control-center" --> doShift "1"
  ]

-- Status bar configuration
myPP = def
  { ppSep = " | "
  , ppTitle = xmobarColor "#4299e1" ""
  , ppCurrent = xmobarColor "#68d391" ""
  , ppHidden = xmobarColor "#a0aec0" ""
  , ppHiddenNoWindows = xmobarColor "#4a5568" ""
  , ppUrgent = xmobarColor "#fc8181" ""
  , ppOrder = \(ws:_:t:_) -> [ws, t]
  }

-- Startup hook
myStartupHook = do
  spawnOnce "feh --bg-scale /usr/share/pixmaps/nixos-logo.png || feh --bg-fill '#2d3748'"
  spawnOnce "kitty"
  spawnOnce "sleep 3 && xmobar /etc/xmobar/xmobarrc &"

-- Key bindings (minimal - just for omnibar)
myKeys =
  [ ("M-<Space>", spawn "cognito-omnibar")
  , ("M1-<Space>", spawn "cognito-omnibar")
  , ("M-S-c", kill)
  , ("M-S-q", spawn "xmonad --recompile && xmonad --restart")
  , ("M-h", windows W.focusUp)
  , ("M-l", windows W.focusDown)
  , ("M-j", windows W.focusUp)
  , ("M-k", windows W.focusDown)
  , ("M-S-h", windows W.swapUp)
  , ("M-S-l", windows W.swapDown)
  , ("M-S-j", windows W.swapUp)
  , ("M-S-k", windows W.swapDown)
  , ("M-f", spawn "notify-send 'Fullscreen' 'Fullscreen toggle not yet implemented'")
  , ("M-S-<Return>", spawn "kitty")
  , ("M-S-x", spawn "pkill xmobar && sleep 1 && xmobar /etc/xmobar/xmobarrc &")
  , ("M-1", windows $ W.greedyView "1")
  , ("M-2", windows $ W.greedyView "2")
  , ("M-3", windows $ W.greedyView "3")
  , ("M-4", windows $ W.greedyView "4")
  , ("M-5", windows $ W.greedyView "5")
  , ("M-6", windows $ W.greedyView "6")
  , ("M-7", windows $ W.greedyView "7")
  , ("M-8", windows $ W.greedyView "8")
  , ("M-9", windows $ W.greedyView "9")
  , ("M-0", windows $ W.greedyView "10")
  , ("M-S-1", windows $ W.shift "1")
  , ("M-S-2", windows $ W.shift "2")
  , ("M-S-3", windows $ W.shift "3")
  , ("M-S-4", windows $ W.shift "4")
  , ("M-S-5", windows $ W.shift "5")
  , ("M-S-6", windows $ W.shift "6")
  , ("M-S-7", windows $ W.shift "7")
  , ("M-S-8", windows $ W.shift "8")
  , ("M-S-9", windows $ W.shift "9")
  , ("M-S-0", windows $ W.shift "10")
  ]

-- Mouse bindings for window management
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList
  [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
  , ((modMask, button2), (\w -> focus w >> windows W.shiftMaster))
  , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
  ]