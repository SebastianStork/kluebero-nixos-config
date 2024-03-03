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
    };

    # Allow members of wheel to deploy remotely
    security.sudo.extraRules = let
      storePrefix = "/nix/store/*";
      systemName = "nixos-system-${config.networking.hostName}-*";
    in
      lib.mkIf cfg.remoteDeployment.enable [
        {
          groups = ["wheel"];
          commands = [
            {
              command = "/run/current-system/sw/bin/nix-store --serve --write";
              options = ["NOPASSWD"];
            }
          ];
        }
        {
          groups = ["wheel"];
          commands = [
            {
              command = "/run/current-system/sw/bin/nix-env -p /nix/var/nix/profiles/system --set ${storePrefix}-${systemName}";
              options = ["NOPASSWD"];
            }
          ];
        }
        {
          groups = ["wheel"];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER --collect --no-ask-password --pty --quiet --same-dir --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait true";
              options = ["NOPASSWD"];
            }
          ];
        }
        {
          groups = ["wheel"];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER --collect --no-ask-password --pty --quiet --same-dir --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait ${storePrefix}-${systemName}/bin/switch-to-configuration switch";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
  };
}
