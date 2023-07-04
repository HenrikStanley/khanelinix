{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.internal; let
  cfg = config.khanelinix.apps.blender;
in {
  options.khanelinix.apps.blender = with types; {
    enable = mkBoolOpt false "Whether or not to enable Blender.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # TODO: fix when blender builds again
      # blender
    ];
  };
}