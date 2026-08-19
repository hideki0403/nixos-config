{ ... }: {
  programs.thunderbird = {
    enable = true;
    languagePacks = [ "ja" ];

    policies = {
      DisableTelemetry = true;
      DisableAppUpdate = true;
      AppAutoUpdate = false;
      DisableFeedbackCommands = true;
    };

    settings = {
      # Disable telemetry
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.usage.uploadEnabled" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.archive.enabled" = false;

      # UI
      "mailnews.start_page.enabled" = false;
      "mailnews.message_display.disable_remote_image" = false;
      "mail.spellcheck.inline" = true;
      "mailnews.default_sort_order" = 2; # new to old

      # General
      "mail.shell.checkDefaultClient" = false;
      "general.autoScroll" = true;
    };

    profiles.default = {
      isDefault = true;
    };
  };
}
