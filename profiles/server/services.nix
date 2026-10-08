{ ... }:
{
  # Enable watchdog
  systemd.settings.Manager.RuntimeWatchdogSec = "60s";
}
