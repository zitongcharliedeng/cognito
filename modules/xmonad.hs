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
import XMonad.Util.UngrabMouse
import XMonad.Util.SpawnOnce

-- Main configuration
main :: IO ()
main = xmonad $ withSB mySB def
  { modMask = mod4Mask  -- Use Super key as mod
  , terminal = "kitty"
  , borderWidth = 2
  , normalBorderColor = "#2d3748"
  , focusedBorderColor = "#4299e1"
  , layoutHook = myLayout
  , manageHook = myManageHook
  , startupHook = myStartupHook
  } `additionalKeysP` myKeys

-- Status bar configuration
mySB = statusBarProp "xmobar ~/.config/xmobar/xmobarrc" (pure myPP)

-- Layout configuration
myLayout = avoidStruts $ spacing 4 $ tiled ||| Mirror tiled ||| Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    delta = 3/100
    ratio = 1/2

-- Manage hook
myManageHook = composeAll
  [ className =? "firefox" --> doShift "2"
  , className =? "thunar" --> doShift "3"
  , className =? "kitty" --> doShift "1"
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

-- Key bindings (minimal - just for omnibar)
myKeys =
  [ ("M-<Space>", spawn "cognito-omnibar")
  , ("M1-<Space>", spawn "cognito-omnibar")
  ]
