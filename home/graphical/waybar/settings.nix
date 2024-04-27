{ lib }:
{
  mainBar = {
    layer = "top";
    position = "top";
    modules-left = [
      "mpris"
      # "hyprland/window"
    ];
    modules-center = [ "hyprland/workspaces" ];
    modules-right = [
      "custom/notification"
      "backlight"
      "battery"
      "bluetooth"
      # power profiles
      # "upower"
      # "wlr/taskbar"
      "tray"
      # "cpu"
      # "memory"
      # "disk"
      # "keyboard-state"
      "wireplumber"
      "network"
      "privacy"
      "clock"
    ];

    "hyprland/workspaces" = {
      "active-only" = false;
      "all-outputs" = false;
      "format" = "{icon}";
      "on-click" = "activate";
      "on-scroll-up" = "hyprctl dispatch workspace e+1";
      "on-scroll-down" = "hyprctl dispatch workspace e-1";
      "show-special" = false;
      "format-icons" = lib.fold (elem: acc: acc // elem) { } (
        lib.forEach (lib.range 0 4) (i: {
          "${builtins.toString ((10 * i) + 1)}" = "一";
          "${builtins.toString ((10 * i) + 2)}" = "二";
          "${builtins.toString ((10 * i) + 3)}" = "三";
          "${builtins.toString ((10 * i) + 4)}" = "四";
          "${builtins.toString ((10 * i) + 5)}" = "五";
          "${builtins.toString ((10 * i) + 6)}" = "六";
          "${builtins.toString ((10 * i) + 7)}" = "七";
          "${builtins.toString ((10 * i) + 8)}" = "八";
          "${builtins.toString ((10 * i) + 9)}" = "九";
          "${builtins.toString ((10 * i) + 10)}" = "十";
        })
      );
    };

    "mpris" = {
      "format" = "{player_icon} {artist} - {title}";
      "format-paused" = "{status_icon}";
      "player-icons" = {
        "chromium" = " ";
        "default" = " ";
        "firefox" = " ";
        "kdeconnect" = " ";
        "mopidy" = " ";
        "mpv" = "󰐹 ";
        "spotify" = " ";
        "vlc" = "󰕼 ";
      };
      "status-icons" = {
        "paused" = " ";
        "playing" = " ";
        "stopped" = " ";
      };
    };

    "network" = {
      "format-ethernet" = "󰈀";
      "format-wifi" = "{essid} ({signalStrength}%) ";
      "tooltip-format" = "{ipaddr}/{cidr} via {gwaddr} on {ifname}";
    };

    "custom/notification" = {
      "tooltip" = false;
      "format" = " {icon} ";
      "format-icons" = {
        "notification" = "<span foreground='red'><sup></sup></span>";
        "none" = "";
        "dnd-notification" = "<span foreground='red'><sup></sup></span>";
        "dnd-none" = "";
        "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
        "inhibited-none" = "";
        "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
        "dnd-inhibited-none" = "";
      };
      "return-type" = "json";
      "exec-if" = "which swaync-client";
      "exec" = "swaync-client -swb";
      "on-click" = "swaync-client -t -sw";
      "on-click-right" = "swaync-client -d -sw";
      "escape" = true;
    };
  };
}
