{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.internal; let
  cfg = config.khanelinix.suites.video;
in {
  options.khanelinix.suites.video = with types; {
    enable = mkBoolOpt false "Whether or not to enable video configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
    ];

    homebrew = {
      enable = true;

      global = {
        brewfile = true;
      };

      masApps = {
        "Infuse" = 1136220934;
        "iMovie" = 408981434;
        "Prime Video" = 545519333;
      };
    };
  };
}