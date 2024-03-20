{
  config,
  pkgs,
  lib,
  ...
}: let 
  nextcloudVirtualHost = config.networking.domain;
  onlyofficeVirtualHost = "only.${nextcloudVirtualHost}";
in {
  options.myConfig.nextcloud.enable = lib.mkEnableOption "nextcloud";

  config = lib.mkIf config.myConfig.nextcloud.enable {
    networking.firewall.allowedTCPPorts = [443 80];
    
    sops.secrets = {
      ssl-cert = {
        owner = config.services.nginx.user;
        group = config.services.nginx.group;
      };
      ssl-key = {
        owner = config.services.nginx.user;
        group = config.services.nginx.group;
      };
      nextcloud-admin-pass = {
        owner = config.services.nextcloud.config.dbname;
        group = config.services.nextcloud.config.dbuser;
      };
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        ${nextcloudVirtualHost} = {
          forceSSL = true;
          sslCertificate = config.sops.secrets.ssl-cert.path;
          sslCertificateKey = config.sops.secrets.ssl-key.path;
        };
        ${onlyofficeVirtualHost} = {
          forceSSL = true;
          sslCertificate = config.sops.secrets.ssl-cert.path;
          sslCertificateKey = config.sops.secrets.ssl-key.path;
        };
      };
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      hostName = nextcloudVirtualHost;
      https = true;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) contacts calendar onlyoffice;
      };

      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        overwriteProtocol = "https";

        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloud-admin-pass.path;
      };
    };

    services.onlyoffice = {
      enable = true;
      hostname = onlyofficeVirtualHost;
    };
  };
}
