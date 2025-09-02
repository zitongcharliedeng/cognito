{ config, pkgs, ... }:
# TODO rename home/ folder to really be system or hardware agnostic or main
{
  # ============================================================================
  # CORE SYSTEM CONFIGURATION (Hardware Agnostic)
  # ============================================================================
  
  # SSH service
  services.openssh.enable = true;
  
  # X server
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  
  # Auto-login for root (useful for headless/VM setups)
  services.getty.extraArgs = [ "--autologin" "root" ];
  
  # Root user configuration
  users.users.root = {
    isNormalUser = false;
    # Note: Password is the same as your NixOS installer sudo password
    # The initialPassword setting is ignored in this context
  };
  
  # ============================================================================
  # DISPLAY MANAGER - Awesome WM + Cognito Omnibar
  # ============================================================================
  
  # Graphical login
  services.xserver.displayManager.lightdm.enable = true;
  
  # LightDM basic configuration TODO autofill the root username
  services.xserver.displayManager.lightdm.greeters.gtk.indicators = [ "hostname" "clock" "session" ];
  
  # Set Awesome as the default session (NixOS way)
  services.xserver.displayManager.defaultSession = "none+awesome";
  


  # Enable Awesome WM
  services.xserver.windowManager.awesome.enable = true;
  
  # Create Awesome WM configuration directory and file
  systemd.tmpfiles.rules = [
    "d /root/.config/awesome 0755 root root -"
    "L+ /root/.config/awesome/rc.lua - - - - ${pkgs.writeText "awesome-config" ''
      -- Cognito OS Awesome WM Configuration
      -- Migrated from i3 due to bar customization issues with i3 migration script
      -- Zero keyboard shortcuts - all actions via rofi omnibar
      
      local awful = require("awful")
      local beautiful = require("beautiful")
      local gears = require("gears")
      local wibox = require("wibox")
      
      -- Initialize theme
      beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
      
      -- Set wallpaper (use a solid color if nixos-logo.png doesn't exist)
      awful.spawn.with_shell("feh --bg-scale /usr/share/pixmaps/nixos-logo.png || feh --bg-fill '#2d3748'")
      
      -- Create top status bar
      local mywibox = awful.wibar({ position = "top", height = 30 })
      
      -- Add widgets to the wibox
      mywibox:setup {
          layout = wibox.layout.align.horizontal,
          { -- Left widgets
              layout = wibox.layout.fixed.horizontal,
              awful.widget.taglist {
                  screen  = screen[1],
                  filter  = awful.widget.taglist.filter.all,
                  buttons = {},
              },
          },
          { -- Middle widget
              layout = wibox.layout.flex.horizontal,
          },
          { -- Right widgets
              layout = wibox.layout.fixed.horizontal,
              wibox.widget.systray(),
              wibox.widget.textclock(),
          },
      }
      
      -- Global key bindings (minimal - just for essential functions)
      local globalkeys = gears.table.join(
          -- Launch omnibar with Meta+Space
          awful.key({ "Mod4" }, "space", function() awful.spawn("cognito-omnibar") end,
                    {description = "Launch Cognito Omnibar", group = "launcher"}),
          -- Launch omnibar with Alt+Space (alternative)
          awful.key({ "Mod1" }, "space", function() awful.spawn("cognito-omnibar") end,
                    {description = "Launch Cognito Omnibar (Alt)", group = "launcher"}),
          -- Reload config
          awful.key({ "Mod4", "Control" }, "r", awesome.restart,
                    {description = "reload awesome", group = "awesome"}),
          -- Quit awesome
          awful.key({ "Mod4", "Shift" }, "q", awesome.quit,
                    {description = "quit awesome", group = "awesome"})
      )
      
      -- Set root keys
      root.keys(globalkeys)
      
      -- Client key bindings (minimal)
      local clientkeys = gears.table.join(
          -- Close window
          awful.key({ "Mod4", "Shift" }, "c", function (c) c:kill() end,
                    {description = "close", group = "client"})
      )
      
      -- Client buttons (minimal)
      local clientbuttons = gears.table.join(
          awful.button({ }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
          awful.button({ "Mod4" }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.move(c) end),
          awful.button({ "Mod4" }, 3, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.resize(c) end)
      )
      
      -- Set client keys and buttons
      root.buttons(gears.table.join())
      
      -- Rules for new clients
      awful.rules.rules = {
          { rule = { }, properties = { border_width = beautiful.border_width,
                                     border_color = beautiful.border_normal,
                                     focus = awful.client.focus.filter,
                                     raise = true,
                                     keys = clientkeys,
                                     buttons = clientbuttons,
                                     screen = awful.screen.preferred,
                                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
          }},
      }
      
      -- Signal function to execute when a new client appears
      client.connect_signal("manage", function (c)
          if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
              awful.placement.no_offscreen(c)
          end
      end)
      
      -- Auto-start applications after Awesome is fully loaded
      awesome.connect_signal("startup", function()
          awful.spawn.with_shell("kitty")
      end)
      
      -- Enable sloppy focus, so that focus follows mouse
      client.connect_signal("mouse::enter", function(c)
          c:emit_signal("request::activate", "mouse_enter", {raise = false})
      end)
      
      -- Auto-start applications
      awful.spawn.with_shell("kitty")
    ''}"
  ];

  # System packages (all hardware agnostic)
  environment.systemPackages = with pkgs; [
    # Core tools
    git
    vim
    htop
    tmux
    neofetch  # system info display
    bat       # better cat with syntax highlighting
    fd        # better find command
    # Display manager packages
    kitty     # hardware-agnostic terminal
    scrot     # screenshot tool
    xclip     # clipboard utility
    xfce.thunar  # file manager
    firefox   # web browser
    gnome.gnome-control-center # settings
    libnotify # for notifications (debug commands)
    alsa-utils # for volume control (amixer)
    brightnessctl # for brightness control
    # Awesome WM dependencies
    rofi      # application launcher for omnibar
    feh       # wallpaper setter
    awesome   # awesome-client command
    i3lock    # screen locker (used in omnibar commands)
    

    
    # Custom omnibar script with explicit bash dependency
    (pkgs.writeScriptBin "cognito-omnibar" ''
      #!${pkgs.bash}/bin/bash
      
      # Comprehensive command database
      commands=(
          # === APPLICATIONS ===
          "new terminal:kitty"
          "terminal:kitty"
          "file manager:thunar"
          "browser:firefox"
          "web browser:firefox"
          "text editor:vim"
          "settings:gnome-control-center"
          "screenshot:scrot -d 1 ~/screenshot-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Saved and copied to clipboard'"
          "screenshot window:scrot -s ~/screenshot-window-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-window-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Window screenshot saved and copied'"
          "screenshot area:scrot -s ~/screenshot-area-$(date +%Y%m%d-%H%M%S).png && xclip -selection clipboard -t image/png < ~/screenshot-area-$(date +%Y%m%d-%H%M%S).png && notify-send 'Screenshot' 'Area screenshot saved and copied'"
          
          # === WORKSPACES (1-10) ===
          "workspace 1:awesome-client 'awful.tag.viewonly(tags[1][1])'"
          "workspace 2:awesome-client 'awful.tag.viewonly(tags[1][2])'"
          "workspace 3:awesome-client 'awful.tag.viewonly(tags[1][3])'"
          "workspace 4:awesome-client 'awful.tag.viewonly(tags[1][4])'"
          "workspace 5:awesome-client 'awful.tag.viewonly(tags[1][5])'"
          "workspace 6:awesome-client 'awful.tag.viewonly(tags[1][6])'"
          "workspace 7:awesome-client 'awful.tag.viewonly(tags[1][7])'"
          "workspace 8:awesome-client 'awful.tag.viewonly(tags[1][8])'"
          "workspace 9:awesome-client 'awful.tag.viewonly(tags[1][9])'"
          "workspace 10:awesome-client 'awful.tag.viewonly(tags[1][10])'"
          "go to workspace 1:awesome-client 'awful.tag.viewonly(tags[1][1])'"
          "go to workspace 2:awesome-client 'awful.tag.viewonly(tags[1][2])'"
          "go to workspace 3:awesome-client 'awful.tag.viewonly(tags[1][3])'"
          "go to workspace 4:awesome-client 'awful.tag.viewonly(tags[1][4])'"
          "go to workspace 5:awesome-client 'awful.tag.viewonly(tags[1][5])'"
          
          # === WINDOW MANAGEMENT ===
          "close window:awesome-client 'client.focus:kill()'"
          "close this window:awesome-client 'client.focus:kill()'"
          "quit window:awesome-client 'client.focus:kill()'"
          "split horizontal:awesome-client 'awful.client.setmaster(client.focus)'"
          "split vertical:awesome-client 'awful.client.setslave(client.focus)'"
          "split horizontally:awesome-client 'awful.client.setmaster(client.focus)'"
          "split vertically:awesome-client 'awful.client.setslave(client.focus)'"
          "fullscreen:awesome-client 'client.focus.fullscreen = not client.focus.fullscreen'"
          "toggle fullscreen:awesome-client 'client.focus.fullscreen = not client.focus.fullscreen'"
          "floating window:awesome-client 'client.focus.floating = not client.focus.floating'"
          "toggle floating:awesome-client 'client.focus.floating = not client.focus.floating'"
          "maximize window:awesome-client 'client.focus.maximized = not client.focus.maximized'"
          
          # === FOCUS & MOVE ===
          "focus window left:awesome-client 'awful.client.focus.bydirection(\"left\")'"
          "focus window right:awesome-client 'awful.client.focus.bydirection(\"right\")'"
          "focus window up:awesome-client 'awful.client.focus.bydirection(\"up\")'"
          "focus window down:awesome-client 'awful.client.focus.bydirection(\"down\")'"
          "move window left:awesome-client 'awful.client.swap.bydirection(\"left\")'"
          "move window right:awesome-client 'awful.client.swap.bydirection(\"right\")'"
          "move window up:awesome-client 'awful.client.swap.bydirection(\"up\")'"
          "move window down:awesome-client 'awful.client.swap.bydirection(\"down\")'"
          
          # === LAYOUTS ===
          "layout stacking:awesome-client 'awful.layout.set(awful.layout.suit.stack)'"
          "layout tabbed:awesome-client 'awful.layout.set(awful.layout.suit.tile)'"
          "layout toggle:awesome-client 'awful.layout.inc(1)'"
          "stacking layout:awesome-client 'awful.layout.set(awful.layout.suit.stack)'"
          "tabbed layout:awesome-client 'awful.layout.set(awful.layout.suit.tile)'"
          "tile layout:awesome-client 'awful.layout.set(awful.layout.suit.tile)'"
          
          # === SYSTEM CONTROL ===
          "shutdown:systemctl poweroff"
          "shut down:systemctl poweroff"
          "power off:systemctl poweroff"
          "reboot:systemctl reboot"
          "restart:systemctl reboot"
          "logout:awesome-client 'awesome.quit()'"
          "log out:awesome-client 'awesome.quit()'"
          "exit awesome:awesome-client 'awesome.quit()'"
          "lock screen:awesome-client 'awful.spawn(\"i3lock\")'"
          "lock:awesome-client 'awful.spawn(\"i3lock\")'"
          
          # === VOLUME CONTROL ===
          "volume up:amixer set Master 5%+"
          "volume down:amixer set Master 5%-"
          "volume mute:amixer set Master toggle"
          "mute:amixer set Master toggle"
          "unmute:amixer set Master unmute"
          "volume 50:amixer set Master 50%"
          "volume 100:amixer set Master 100%"
          
          # === BRIGHTNESS CONTROL ===
          "brightness up:brightnessctl set 5%+"
          "brightness down:brightnessctl set 5%-"
          "brightness max:brightnessctl set 100%"
          "brightness min:brightnessctl set 10%"
          "brightness 50:brightnessctl set 50%"
          
          # === AWESOME CONTROL ===
          "reload config:awesome-client 'awesome.restart()'"
          "restart awesome:awesome-client 'awesome.restart()'"
          "reload awesome:awesome-client 'awesome.restart()'"
          "restart window manager:awesome-client 'awesome.restart()'"
          
          # === DEBUG & TEST ===
          "debug:echo 'Omnibar working!' && notify-send 'Debug' 'Omnibar is functional'"
          "test:notify-send 'Test' 'This is a test notification'"
          "check rofi:rofi -dmenu -i -p 'Rofi Test'"
          "test kitty:kitty &"
          "test firefox:firefox &"
      )
      
      # Show commands with rofi
      if command -v rofi >/dev/null 2>&1; then
          input=$(printf '%s\n' "''${commands[@]}" | rofi -dmenu -i -p "🔍 Cognito Omnibar" -width 60 -lines 20)
          
          if [[ -n "$input" ]]; then
              cmd=$(echo "$input" | cut -d: -f2)
              echo "Executing: $cmd"
              # Log to a file for debugging
              echo "$(date): Executing command: $cmd" >> /tmp/cognito-omnibar.log
              # Execute command in background to avoid blocking rofi
              eval "$cmd &"
          fi
      else
          echo "Rofi not found"
      fi
    '')
  ];


}
