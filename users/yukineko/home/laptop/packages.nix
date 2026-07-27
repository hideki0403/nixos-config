{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    godot
    blender
    libreoffice-fresh
    wireshark
    microsoft-edge
    anki
  ];
}
