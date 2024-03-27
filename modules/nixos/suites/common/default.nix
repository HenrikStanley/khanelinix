{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.internal) enabled;

  cfg = config.khanelinix.suites.common;
in
{
  imports = [ ../../../shared/suites/common/default.nix ];

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      appimage-run
      clac
      fastfetch
      feh
      jq
      khanelinix.trace-symlink
      khanelinix.trace-which
      ncdu
      toilet
      tree
      upower
      util-linux
    ];

    khanelinix = {
      cli-apps = {
        ranger = enabled;
      };

      hardware = {
        power = enabled;
      };

      nix = enabled;

      security = {
        gpg = enabled;
      };

      services = {
        openssh = enabled;
        printing = enabled;
        tailscale = enabled;
      };

      system = {
        fonts = enabled;
        locale = enabled;
        time = enabled;
      };

      tools = {
        colorls = enabled;
        fup-repl = enabled;
        glxinfo = enabled;
        nix-ld = enabled;
      };
    };
  };
}
