{ config, pkgs, lib, ... }:
let
  fsHandle = "FS1";
  esp = config.boot.loader.efi.efiSysMountPoint;
in
{
  system.activationScripts.windowsBootEntry.text = ''
    mkdir -p ${esp}/efi/edk2-uefi-shell ${esp}/loader/entries

    ${lib.getExe' pkgs.sbsigntool "sbsign"} \
      --key ${config.boot.lanzaboote.privateKeyFile} \
      --cert ${config.boot.lanzaboote.publicKeyFile} \
      --output ${esp}/efi/edk2-uefi-shell/shell.efi \
      ${pkgs.edk2-uefi-shell}/shell.efi

    cat > ${esp}/loader/entries/windows.conf <<'EOF'
    title Windows
    efi /efi/edk2-uefi-shell/shell.efi
    options -nointerrupt -nomap -noversion ${fsHandle}:EFI\Microsoft\Boot\Bootmgfw.efi
    sort-key y_windows
    EOF

    cat > ${esp}/loader/entries/edk2-uefi-shell.conf <<'EOF'
    title EDK2 UEFI Shell
    efi /efi/edk2-uefi-shell/shell.efi
    sort-key z_edk2
    EOF
  '';
}
