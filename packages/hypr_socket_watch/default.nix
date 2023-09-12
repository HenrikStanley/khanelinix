{ writeShellApplication
, pkgs
, ...
}:
writeShellApplication
{
  name = "hypr_socket_watch";

  meta = {
    mainProgram = "hypr_socket_watch";
  };

  text = ''
    # shellcheck disable=SC1091
    source ${./bash-functions.sh}

    handle() {
      case $1 in
        monitoradded*) echo "$1" ;;
        focusedmon*) echo "$1" ;;
        workspace*)
          local workspace
          workspace=$(extract_after_double_arrow "$1")
          local wallpaper
          wallpaper=$(nth_file "${pkgs.khanelinix.wallpapers}/share/wallpapers" "$workspace")
          "${pkgs.hyprland}/bin/hyprctl" hyprpaper wallpaper "DP-1,$wallpaper"
          ;;
      esac
    }

    socat -U - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | while read -r line; do handle "$line"; done
  '';
}

