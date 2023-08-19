{ lib
, config
, pkgs
, inputs
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.khanelinix.system.shell.zsh;
in
{
  options.khanelinix.system.shell.zsh = {
    enable = mkEnableOption "ZSH";
  };

  config = mkIf cfg.enable {
    home = {
      file = with inputs; {
        ".p10k.zsh".source = dotfiles.outPath + "/dots/shared/home/.p10k.zsh";
        ".functions".source = dotfiles.outPath + "/dots/shared/home/.functions";
      };
    };

    programs = {
      zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;

        sessionVariables = {
          KEYTIMEOUT = 1;
        };

        initExtraFirst = ''
          export PATH="$PATH:/opt/local/bin:/opt/local/sbin:$HOME/.local/share/pnpm:~/.spicetify:$HOME/.cargo/bin"
          PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"
        '';

        initExtra = ''          
          # Use vim bindings.
          set -o vi

          # Improved vim bindings.
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

          source ~/.functions

          if [ "$TMUX" = "" ]; then command -v tmux && tmux; fi

          fastfetch
        '';

        shellAliases = { };

        plugins = [
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.4.0";
              sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
            };
          }
        ];
      };
    };
  };
}