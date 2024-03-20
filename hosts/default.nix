{
  config,
  pkgs,
  ...
}: {
  imports = [../modules];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    trusted-users = ["root" "@wheel"];
  };

  nixpkgs.config.allowUnfree = true;

  sops.secrets = {
    "password/seb".neededForUsers = true;
    "password/julius".neededForUsers = true;
    "password/paul".neededForUsers = true;
  };

  users = {
    mutableUsers = false;

    users = {
      seb = {
        isNormalUser = true;
        description = "Sebastian Stork";
        hashedPasswordFile = config.sops.secrets."password/seb".path;
        extraGroups = ["wheel"];
      };

      julius = {
        isNormalUser = true;
        description = "Julius Steude";
        hashedPasswordFile = config.sops.secrets."password/julius".path;
        extraGroups = ["wheel"];
      };

      paul = {
        isNormalUser = true;
        description = "Paul Kiffer";
        hashedPasswordFile = config.sops.secrets."password/paul".path;
        extraGroups = ["wheel"];
      };
    };
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

  console.keyMap = "de-latin1-nodeadkeys";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  environment.systemPackages = [
    pkgs.neovim
    pkgs.git
    pkgs.cowsay
  ];

  system.stateVersion = "23.11";
}
