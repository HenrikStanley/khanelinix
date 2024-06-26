{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.internal) enabled;

  cfg = config.khanelinix.suites.common;
in
{
  imports = [ ../../../shared/suites/common/default.nix ];

  config = mkIf cfg.enable {
    programs.zsh.enable = true;

    homebrew = {
      brews = [ "bashdb" ];
    };

    environment = {
      loginShell = pkgs.zsh;

      systemPackages = with pkgs; [
        bash-completion
        cask
        duti
        fasd
        gawk
        gnugrep
        gnupg
        gnused
        gnutls
        haskellPackages.sfnt2woff
        intltool
        keychain
        khanelinix.trace-symlink
        khanelinix.trace-which
        mas
        moreutils
        ncdu
        oh-my-posh
        pigz
        rename
        spice-gtk
        terminal-notifier
        trash-cli
        tree
        wtf
      ];
    };

    khanelinix = {
      nix = enabled;

      tools = {
        homebrew = enabled;
      };

      system = {
        fonts = enabled;
        input = enabled;
        interface = enabled;
        networking = enabled;
      };
    };
  };
}
