{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "kluebero-vm1";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  boot.tmp.cleanOnBoot = true;
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 50;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  system.stateVersion = "23.11";
}
