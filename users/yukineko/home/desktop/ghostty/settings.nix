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

      # Ghosttyのshell-integration (ssh-env) によって`~/.ssh/config`に書いたSetEnvが無視される問題があるので一時的に無効化しておく
      # 1.3.2で修正が反映予定?
      # ref: https://github.com/ghostty-org/ghostty/pull/11518

      # shell-integration-features = "ssh-env,ssh-terminfo";
      shell-integration-features = "";
    };
  };
}
