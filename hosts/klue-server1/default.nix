{inputs, ...}: {
    imports = [
        ./hardware-configuration.nix
        ../.

        inputs.disko.nixosModules.default
        (import ../disko.nix {device = "/dev/sda";})
    ];

    networking.hostName = "klue-server1";
    networking.domain = "kluebero.lgs-hanau.de";

    myConfig = {
        ssh = {
            enable = true;
            users = ["seb" "julius" "paul"];
            remoteDeployment.enable = true;
        };
        sops.enable = true;
        nextcloud.enable = true;
        matrix.enable = true;
    };
}
