{
  config,
  lib,
  ...
}: let
  matrixVirtualHost = "matrix.${config.networking.domain}";
in {
  options.myConfig.matrix.enable = lib.mkEnableOption "";

  config = lib.mkIf config.myConfig.matrix.enable {
    networking.firewall.allowedTCPPorts = [443];

    sops.secrets = {
      ssl-cert = {
        owner = config.services.nginx.user;
        group = config.services.nginx.group;
      };
      ssl-key = {
        owner = config.services.nginx.user;
        group = config.services.nginx.group;
      };
      matrix-shared-secret = {
        owner = config.systemd.services.matrix-synapse.serviceConfig.User;
        group = config.systemd.services.matrix-synapse.serviceConfig.Group;
      };
    };

    services.postgresql = {
      enable = true;

      ensureUsers = [
        {
          name = "matrix-synapse";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [
        "matrix-synapse"
      ];
      initdbArgs = [
        "--locale=C"
        "--encoding=UTF8"
      ];
    };

    services.nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        ${matrixVirtualHost} = {
          forceSSL = true;
          sslCertificate = config.sops.secrets.ssl-cert.path;
          sslCertificateKey = config.sops.secrets.ssl-key.path;

          locations."/".extraConfig = ''
            return 404;
          '';

          locations."/_matrix".proxyPass = "http://localhost:8008";
          locations."/_synapse/client".proxyPass = "http://localhost:8008";
        };
      };
    };

    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = matrixVirtualHost;
        public_baseurl = "https://${matrixVirtualHost}";
        database.name = "psycopg2";
        listeners = [
          {
            port = 8008;
            bind_addresses = ["127.0.0.1"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = ["client" "federation"];
                compress = true;
              }
            ];
          }
        ];
      };
      extraConfigFiles = [config.sops.secrets.matrix-shared-secret.path];
    };
  };
}