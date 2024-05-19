{ pkgs, inputs, ... }:
{
  imports = [
    ./graphical
    ./services

    ./nixpkgs.nix
    ./sound.nix
    ./wireguard.nix
  ];

  config = {
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;

    boot.loader.efi.canTouchEfiVariables = true;

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "de_DE.UTF-8";

      supportedLocales = [
        "de_DE.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];

      extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
    };

    # Configure console keymap
    console.keyMap = "neoqwertz";

    environment.shells = [ pkgs.zsh ];
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    programs.ssh.startAgent = true;

    systemd.user.services.ssh-agent = {
      serviceConfig = {
        ExecStartPost = "${pkgs.systemd}/bin/systemctl --user set-environment SSH_AUTH_SOCK=%t/ssh-agent";
        ExecStopPost = "${pkgs.systemd}/bin/systemctl --user unset-environment SSH_AUTH_SOCK";
      };
    };

    services.dbus = {
      implementation = "broker";
    };

    programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [
      neovim
      helix
      git
      jq
    ];

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      settings = (import ../flake.nix).nixConfig;
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
        unstable.flake = inputs.nixpkgs-unstable;
      };
    };
  };
}
