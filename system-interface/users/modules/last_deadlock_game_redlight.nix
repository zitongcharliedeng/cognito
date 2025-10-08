{ config, pkgs, lib, ... }:

let
  # Small helper: the red filter CLI (xcalib-based), packaged immutably.
  redscreen = pkgs.writeShellScriptBin "redscreen" ''
    set -euo pipefail

    # Ensure X11 session vars for user services
    export DISPLAY="''${DISPLAY:-:0}"
    export XAUTHORITY="''${XAUTHORITY:-$HOME/.Xauthority}"

    cmd="''${1:-on}"

    case "$cmd" in
      off)
        ${pkgs.xcalib}/bin/xcalib -clear
        ;;
      inv)
        ${pkgs.xcalib}/bin/xcalib -i -a
        ;;
      dim)
        ${pkgs.xcalib}/bin/xcalib -clear
        ${pkgs.xcalib}/bin/xcalib -co 30 -alter
        ;;
      on|red)
        # Template you provided, applied cleanly
        ${pkgs.xcalib}/bin/xcalib -clear
        ${pkgs.xcalib}/bin/xcalib -green .1 0 1 -alter
        ${pkgs.xcalib}/bin/xcalib -blue  .1 0 1 -alter
        ${pkgs.xcalib}/bin/xcalib -red   0.5 1 40 -alter
        ;;
      *)
        echo "Usage: redscreen {on|off|dim|inv}" >&2
        exit 2
        ;;
    esac
  '';

  # One-shot that checks the clock at login and applies the correct state immediately.
  applyNow = pkgs.writeShellScriptBin "redscreen-apply-now" ''
    set -euo pipefail
    export DISPLAY="''${DISPLAY:-:0}"
    export XAUTHORITY="''${XAUTHORITY:-$HOME/.Xauthority}"

    # Current local time HHMM, compare across midnight
    now="$(date +%H%M)"
    if [ "$now" -ge 2100 ] || [ "$now" -lt 0600 ]; then
      exec ${redscreen}/bin/redscreen on
    else
      exec ${redscreen}/bin/redscreen off
    fi
  '';
in
{
  # Make sure xcalib is available (and our helper binaries)
  home.packages = lib.mkAfter [ pkgs.xcalib redscreen applyNow ];


  # systemd — user services (oneshot) + timers (OnCalendar, Persistent=true)
  systemd.user = {
    services = {
      "redscreen-on" = {
        Unit = {
          Description = "Enable redscreen (night vision)";
        };
        Service = {
          Type = "oneshot";
          Environment = [
            "DISPLAY=:0"
            "XAUTHORITY=%h/.Xauthority"
          ];
          ExecStart = "${redscreen}/bin/redscreen on";
        };
      };

      "redscreen-off" = {
        Unit = {
          Description = "Disable redscreen (back to normal)";
        };
        Service = {
          Type = "oneshot";
          Environment = [
            "DISPLAY=:0"
            "XAUTHORITY=%h/.Xauthority"
          ];
          ExecStart = "${redscreen}/bin/redscreen off";
        };
      };

      # Apply the correct state right when your user session starts.
      "redscreen-apply-now" = {
        Unit = {
          Description = "Apply redscreen state based on current time at login";
          # Make sure it waits until the X session is up in typical GNOME user sessions.
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          Environment = [
            "DISPLAY=:0"
            "XAUTHORITY=%h/.Xauthority"
          ];
          ExecStart = "${applyNow}/bin/redscreen-apply-now";
        };
        Install = {
          WantedBy = [ "default.target" "graphical-session.target" ];
        };
      };
    };

    timers = {
      "redscreen-on" = {
        Unit = { Description = "Schedule redscreen ON at 21:00 daily"; };
        Timer = {
          OnCalendar = "*-*-* 21:00";
          Persistent = true;  # catch up if logged in after 21:00
          Unit = "redscreen-on.service";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };

      "redscreen-off" = {
        Unit = { Description = "Schedule redscreen OFF at 06:00 daily"; };
        Timer = {
          OnCalendar = "*-*-* 06:00";
          Persistent = true;  # catch up if the machine was off at 06:00
          Unit = "redscreen-off.service";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
    };
  };
}
