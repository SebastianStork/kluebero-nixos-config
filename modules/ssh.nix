{
  config,
  lib,
  ...
}: let
  cfg = config.myConfig.ssh;
in {
  options.myConfig.ssh = {
    enable = lib.mkEnableOption "openSSH";

    remoteDeployment.enable = lib.mkEnableOption "remote deyployment";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The users that will have ssh access.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users = {
      seb.openssh.authorizedKeys.keys = lib.mkIf (builtins.elem "seb" cfg.users) ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE69lHVlHYqco1KIcLvoceilJlDZOp9hfBlSBOnvPuRO seb"];
      julius.openssh.authorizedKeys.keys = lib.mkIf (builtins.elem "julius" cfg.users) ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILHkOQQHkoYY/NYv4pf44rXjjDW6ISd8C232mE8criuc julius"];
      paul.openssh.authorizedKeys.keys = lib.mkIf (builtins.elem "paul" cfg.users) ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5TW4AO+I2qbwZFO4lfr6QQiKP+HBe2SAzYDccv8hgr paul"];
    };

    # Allow members of wheel to deploy remotely
    security.sudo.extraRules = let
      commandPrefix = "/run/current-system/sw/bin";
      storePrefix = "/nix/store/*";
      systemName = "nixos-system-${config.networking.hostName}-*";
    in
      lib.lists.forEach [
        "${commandPrefix}/nix-store --serve --write"
        "${commandPrefix}/nix-env -p /nix/var/nix/profiles/system --set ${storePrefix}-${systemName}"
        "${commandPrefix}/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER --collect --no-ask-password --pty --quiet --same-dir --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait true"
        "${commandPrefix}/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER --collect --no-ask-password --pty --quiet --same-dir --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait ${storePrefix}-${systemName}/bin/switch-to-configuration switch"
      ] (command: {
        groups = ["wheel"];
        commands = [
          {
            inherit command;
            options = ["NOPASSWD"];
          }
        ];
      });
  };
}
