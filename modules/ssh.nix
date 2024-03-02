{
  config,
  lib,
  ...
}: {
  options.myConfig.ssh.enable = lib.mkEnableOption "openSSH";

  config = lib.mkIf config.myConfig.ssh.enable {
    users.users = {
      root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHubTY+B7iIs6cWlAKFcilbsl6eRkWgugo6KWxRYcP8h root"];
      seb.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE69lHVlHYqco1KIcLvoceilJlDZOp9hfBlSBOnvPuRO seb"];
    };

    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
