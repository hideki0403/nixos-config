{ pkgs, ... }: {
  home.packages = with pkgs; [
    godot
    blender
    wireshark
    microsoft-edge
    anki
  ];
}
