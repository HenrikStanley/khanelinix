{ config
, lib
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.khanelinix.cli-apps.helix;
in
{
  imports = lib.snowfall.fs.get-non-default-nix-files ./.;

  options.khanelinix.cli-apps.helix = {
    enable = mkEnableOption "Helix";
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      # package = inputs.helix.packages.default.overrideAttrs (self: {
      #   makeWrapperArgs = with pkgs;
      #     self.makeWrapperArgs
      #     or []
      #     ++ [
      #       "--suffix"
      #       "PATH"
      #       ":"
      #       (lib.makeBinPath [
      #         clang-tools
      #         marksman
      #         nil
      #         nodePackages.bash-language-server
      #         nodePackages.vscode-css-languageserver-bin
      #         nodePackages.vscode-langservers-extracted
      #         shellcheck
      #       ])
      #     ];
      # });

      settings = {
        theme = "catppuccin_macchiato";
        editor = {
          color-modes = true;
          cursorline = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides = {
            render = true;
            rainbow-option = "dim";
          };
          lsp.display-inlay-hints = true;
          # rainbow-brackets = true;
          statusline.center = [ "position-percentage" ];
          true-color = true;
          whitespace.characters = {
            newline = "↴";
            tab = "⇥";
          };
        };

        keys.normal.space.u = {
          f = ":format"; # format using LSP formatter
          w = ":set whitespace.render all";
          W = ":set whitespace.render none";
        };
      };
    };
  };
}
