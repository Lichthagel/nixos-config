{ pkgs, ctp, ... }:
{
  imports = [
    ./atuin.nix
    ./starship
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    fd
    du-dust
    skate
    trashy
    croc
  ];

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
    };

    btop = {
      enable = true;
      catppuccin.enable = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
    };

    fzf = {
      enable = true;
      catppuccin.enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
    };

    ripgrep = {
      enable = true;
    };

    skim = {
      enable = true;
      catppuccin.enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
    };

    tealdeer.enable = true;

    zellij = {
      enable = true;
      settings = {
        theme = "catppuccin-${ctp.flavor}";
        copy_command = "wl-copy";
        pane_frames = false;
        ui.pane_frames = {
          rounded_corners = true;
          hide_session_name = true;
        };
      };
    };

    zoxide.enable = true;
  };

  home.shellAliases = {
    zh = "z $PWD";
  };
}
