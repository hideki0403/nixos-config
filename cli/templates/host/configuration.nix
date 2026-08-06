{ ... }:
{
  imports = [
    #{{IMPORTS}}
  ];

  networking.hostName = "{{HOSTNAME}}";
  system.stateVersion = "{{STATE_VERSION}}";

  #{{USER_GROUPS}}
  #{{HOME_MANAGER_USERS}}
}
