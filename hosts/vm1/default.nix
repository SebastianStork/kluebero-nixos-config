{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../.

    inputs.disko.nixosModules.default
    (import ../disko.nix {device = "/dev/sda";})
  ];

  networking.hostName = "kluebero-vm1";

  myConfig = {
    ssh = {
      enable = true;
      users = ["seb" "julius" "paul"];
      remoteDeployment.enable = true;
    };
    sops.enable = true;
  };
}
