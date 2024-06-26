{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (inputs) nixpkgs-wayland hyprland-contrib;
  inherit (lib) mkIf getExe getExe';

  convert = getExe' pkgs.imagemagick "convert";
  grim = getExe nixpkgs-wayland.packages.${system}.grim;
  # TODO: check to see if it works again later, getting a slurp wl-pointer error
  # slurp = getExe nixpkgs-wayland.packages.${system}.slurp;
  slurp = getExe pkgs.slurp;
  wl-copy = getExe' nixpkgs-wayland.packages.${system}.wl-clipboard "wl-copy";
  wl-paste = getExe' nixpkgs-wayland.packages.${system}.wl-clipboard "wl-paste";

  getDateTime = getExe (
    pkgs.writeShellScriptBin "getDateTime" # bash
      ''
        echo $(date +'%Y%m%d_%H%M%S')
      ''
  );

  screenshot-path = "/home/${config.khanelinix.user.name}/Pictures/screenshots";

  cfg = config.khanelinix.desktop.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        animations = {
          enabled = "yes";

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
          bezier = [
            "easein, 0.47, 0, 0.745, 0.715"
            "myBezier, 0.05, 0.9, 0.1, 1.05"
            "overshot, 0.13, 0.99, 0.29, 1.1"
            "scurve, 0.98, 0.01, 0.02, 0.98"
          ];

          animation = [
            "border, 1, 10, default"
            "fade, 1, 10, default"
            "windows, 1, 5, overshot, popin 10%"
            "windowsOut, 1, 7, default, popin 10%"
            "workspaces, 1, 6, overshot, slide"
          ];
        };

        debug = {
          disable_logs = false;
        };

        decoration = {
          active_opacity = 0.95;
          fullscreen_opacity = 1.0;
          inactive_opacity = 0.9;
          rounding = 10;

          blur = {
            enabled = "yes";
            passes = 4;
            size = 5;
          };

          drop_shadow = true;
          shadow_ignore_window = true;
          shadow_range = 20;
          shadow_render_power = 3;
          "col.shadow" = "0x55161925";
          "col.shadow_inactive" = "0x22161925";
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          force_split = 0;
          preserve_split = true; # you probably want this
          pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        };

        general = {
          allow_tearing = true;
          border_size = 2;
          "col.active_border" = "rgba(7793D1FF)";
          "col.inactive_border" = "rgb(5e6798)";
          gaps_in = 5;
          gaps_out = 20;
          layout = "dwindle";
          no_cursor_warps = true;
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
          workspace_swipe_invert = false;
        };

        input = {
          follow_mouse = 1;
          kb_layout = "us";
          numlock_by_default = true;

          touchpad = {
            disable_while_typing = true;
            natural_scroll = "no";
            tap-to-click = true;
          };

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        master = {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true;
        };

        misc = {
          allow_session_lock_restore = true;
          disable_hyprland_logo = true;
          key_press_enables_dpms = true;
          mouse_move_enables_dpms = true;
          vrr = 2;
        };

        # unscale XWayland
        xwayland = {
          force_zero_scaling = true;
        };

        "$mainMod" = "SUPER";
        "$LHYPER" = "SUPER_LALT_LCTRL"; # TODO: fix
        "$RHYPER" = "SUPER_RALT_RCTRL"; # TODO: fix

        # default applications
        "$term" = "[float;tile] ${getExe pkgs.wezterm} start --always-new-process";
        "$browser" = "${getExe pkgs.firefox}";
        "$mail" = "${getExe pkgs.thunderbird}";
        "$editor" = "${getExe pkgs.neovim}";
        "$explorer" = "${getExe pkgs.xfce.thunar}";
        "$music" = "${getExe pkgs.spotify}";
        "$notification_center" = "${getExe' pkgs.swaynotificationcenter "swaync-client"}";
        "$launcher" = "${getExe config.programs.rofi.package} -show drun -n";
        "$launcher_alt" = "${getExe config.programs.rofi.package} -show calc";
        "$launcher_shift" = "${getExe config.programs.rofi.package} -show run -n";
        "$launchpad" = "${getExe config.programs.rofi.package} -show drun -config '~/.config/rofi/appmenu/rofi.rasi'";
        "$looking-glass" = "${getExe pkgs.looking-glass-client}";
        "$screen-locker" = "${getExe config.programs.hyprlock.package}";
        "$window-inspector" = "${getExe hyprland-contrib.packages.${system}.hyprprop}";
        "$screen-recorder" = "${getExe pkgs.khanelinix.record_screen}";

        # screenshot commands
        "$notify-screenshot" = ''${getExe pkgs.libnotify} --icon "$file" "Screenshot Saved"'';
        "$screenshot-path" = "/home/${config.khanelinix.user.name}/Pictures/screenshots";
        "$screenshot" = ''file="${screenshot-path}/$(${getDateTime}).png" && ${grim} "$file" && $notify-screenshot'';
        "$slurp_screenshot" = ''file="${screenshot-path}/$(${getDateTime}).png" && ${grim} -g "$(${slurp})" "$file" && $notify-screenshot'';
        "$slurp_swappy" = ''${grim} -g "$(${slurp})" - | ${getExe pkgs.swappy} -f -'';
        "$grim_swappy" = "${grim} - | ${getExe pkgs.swappy} -f -";
        "$grimblast_screen" = "${getExe pkgs.grimblast} copy screen && ${wl-paste} -t image/png | ${convert} png:- /tmp/clipboard.png && ${getExe pkgs.libnotify} --icon=/tmp/clipboard.png 'Screen copied to clipboard'";
        "$grimblast_window" = "${getExe pkgs.grimblast} copy active && ${wl-paste} -t image/png | ${convert} png:- /tmp/clipboard.png && ${getExe pkgs.libnotify} --icon=/tmp/clipboard.png 'Window copied to clipboard'";
        "$grimblast_area" = "${getExe pkgs.grimblast} copy area && ${wl-paste} -t image/png | ${convert} png:- /tmp/clipboard.png && ${getExe pkgs.libnotify} --icon=/tmp/clipboard.png 'Area copied to clipboard'";

        # utility commands
        "$color_picker" = "${getExe pkgs.hyprpicker} -a && (${convert} -size 32x32 xc:$(${wl-paste}) /tmp/color.png && ${getExe pkgs.libnotify} \"Color Code:\" \"$(${wl-paste})\" -h \"string:bgcolor:$(${wl-paste})\" --icon /tmp/color.png -u critical -t 4000)";
        "$cliphist" = "${getExe pkgs.cliphist} list | ${getExe config.programs.rofi.package} -dmenu | ${getExe pkgs.cliphist} decode | ${wl-copy}";
      };
    };
  };
}
