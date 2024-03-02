{pkgs, ...}: {
  imports = [../modules];
  
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    trusted-users = ["root" "@wheel"];
  };

  users = {
    mutableUsers = false;

    users = {
      seb = {
        isNormalUser = true;
        description = "Sebastian Stork";
        hashedPassword = "$y$j9T$KeXG5O0SVTpB9JDKKu1hU/$zub/9gM6LGkCWb4Tjt8gFFWpmbNlNEhEOVpmDUWjgk0";
        extraGroups = ["wheel"];
      };

      julius = {
        isNormalUser = true;
        description = "Julius Steude";
        hashedPassword = "$y$j9T$dR5hskt1tyqedNpf4c5Yf1$2fMXtSsSutCD2hEJbi9/1PvQ2c7aG2UBN1zwEJZ4mjA";
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

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  system.stateVersion = "23.11";
}
