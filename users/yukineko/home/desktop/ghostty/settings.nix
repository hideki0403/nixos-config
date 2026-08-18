{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      font-family = [
        "JetBrainsMono Nerd Font"
        "PlemolJP HS"
      ];
      theme = "One Half Dark";
      background-opacity = 0.8;

      window-padding-x = 12;
      window-padding-y = 12;

      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "no-bell,notify";
      notify-on-command-finish-after = "0s";

      shell-integration-features = "ssh-terminfo,ssh-env";
    };
  };
}
