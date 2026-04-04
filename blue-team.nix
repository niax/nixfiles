{ config, ... }: {
  sops.secrets."id_rsa_blue" = {
    sopsFile = ./secrets/blue-team.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_rsa_blue";
  };

  sops.secrets."id_rsa_blue_pub" = {
    sopsFile = ./secrets/blue-team.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_rsa_blue.pub";
  };

  sops.secrets."netbox_environ_blue" = {
    sopsFile = ./secrets/blue-team.yaml;
    path = "${config.home.homeDirectory}/.environ/blue-netbox";
  };
}
