{ ... }:
let
  opacity = "0.9";
in
{
  gtk = {
    enable = true;

    font = {
      name = "Zen Maru Gothic";
      size = 11;
    };

    gtk3.extraCss = ''
      @import url("noctalia.css");

      window.background,
      dialog.background {
        background-color: alpha(@window_bg_color, ${opacity});
      }

      headerbar,
      .titlebar {
        background-color: alpha(@headerbar_bg_color, ${opacity});
      }

      .view,
      list,
      flowbox,
      iconview,
      treeview.view,
      textview text {
        background-color: alpha(@view_bg_color, ${opacity});
      }

      .sidebar,
      stacksidebar,
      placessidebar {
        background-color: alpha(@sidebar_bg_color, ${opacity});
      }

      .card,
      frame.view {
        background-color: alpha(@card_bg_color, ${opacity});
      }
    '';

    gtk4.extraCss = ''
      @import url("noctalia.css");

      :root {
        --window-bg-color: alpha(@window_bg_color, ${opacity});
        --view-bg-color: alpha(@view_bg_color, ${opacity});
        --headerbar-bg-color: alpha(@headerbar_bg_color, ${opacity});
        --sidebar-bg-color: alpha(@sidebar_bg_color, ${opacity});
        --secondary-sidebar-bg-color: alpha(@secondary_sidebar_bg_color, ${opacity});
        --card-bg-color: alpha(@card_bg_color, ${opacity});
        --dialog-bg-color: alpha(@dialog_bg_color, ${opacity});
      }
    '';
  };
}
