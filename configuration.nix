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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  system.stateVersion = "23.11";
}
