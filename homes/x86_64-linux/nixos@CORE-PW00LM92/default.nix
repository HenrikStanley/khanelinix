{ config
, lib
, ...
}:
let
  inherit (lib) mkForce;
  inherit (lib.internal) enabled disabled;
in
{
  khanelinix = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };

    apps = {
      vscode = mkForce disabled;
    };

    cli-apps = {
      home-manager = enabled;
      k9s = enabled;
    };

    security = {
      sops = {
        enable = true;
        defaultSopsFile = ../../../secrets/CORE/nixos/default.yaml;
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };

    system = {
      xdg = enabled;
    };

    suites = {
      common = enabled;
      development = {
        enable = true;
        dockerEnable = true;
      };
    };

    tools = {
      git = {
        enable = true;
        wslAgentBridge = true;
        includes = [
          {
            condition = "gitdir:/mnt/c/";
            path = "${./git/windows-compat-config}";
          }
          {
            condition = "gitdir:/mnt/c/source/repos/DiB/";
            path = "${./git/dib-signing}";
          }
        ];
      };

      ssh = enabled;
    };
  };

  sops.secrets.kubernetes = {
    path = "${config.home.homeDirectory}/.kube/config";
  };

  home.shellAliases = {
    nixcfg = "nvim ~/khanelinix/flake.nix";
  };

  home.stateVersion = "23.11";
}
