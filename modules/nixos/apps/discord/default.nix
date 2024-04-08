{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe;
  inherit (lib.internal) mkBoolOpt;

  cfg = config.khanelinix.apps.discord;
in
{
  options.khanelinix.apps.discord = {
    enable = mkBoolOpt false "Whether or not to enable Discord.";
    canary.enable = mkBoolOpt false "Whether or not to enable Discord Canary.";
    firefox.enable = mkBoolOpt false "Whether or not to enable the Firefox version of Discord.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      lib.optional cfg.enable pkgs.discord
      ++ lib.optional cfg.canary.enable pkgs.khanelinix.discord
      ++ lib.optional cfg.firefox.enable pkgs.khanelinix.discord-firefox;

    system.userActivationScripts = {
      postInstall = # bash
        ''
          echo "Running betterdiscord install"
          source ${config.system.build.setEnvironment}
          ${getExe pkgs.betterdiscordctl} install || true
        '';
    };
  };
}
