{ ... }: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png"  = [ "org.gnome.Loupe.desktop" ];
      "image/gif"  = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
    };
  };
}
