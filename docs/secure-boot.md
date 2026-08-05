# Secure Boot

> [!NOTE]
> まだ初回のrebuildを行っていない場合は、現段階でのconfigを元に`nixos-rebuild`しておく  

## Lanzabooteの導入
1. セキュアブートをONにした状態でPCを再起動する  
2. `sudo sbctl enroll-keys --microsoft`する

```bash
$ sudo sbctl enroll-keys --microsoft
‼ File is immutable: /sys/firmware/efi/efivars/KEK-8be4df61-93ca-11d2-aa0d-00e098032b8c
‼ File is immutable: /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f
You need to chattr -i files in efivarfs
```

3. ファイルの属性がimmutableだからmutableにしろ、とのことなので、以下のコマンドを実行する  
```bash
$ sudo chattr -i /sys/firmware/efi/efivars/KEK-8be4df61-93ca-11d2-aa0d-00e098032b8c
$ sudo chattr -i /sys/firmware/efi/efivars/db-d719b2cb-3d3a-4596-a3bc-dad00e67656f
```

4. もう一度 `sudo sbctl enroll-keys --microsoft` する  
```bash
$ sudo sbctl enroll-keys --microsoft
Enrolling keys to EFI variables...
With vendor keys from microsoft...✓
Enrolled keys to the EFI variables!
```

5. 自身の `hosts/<YOUR_HOST_NAME>/configuration.nix` 内のimportsに以下を追加する
```diff
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
+   ../../modules/hardware/secure-boot
  ];

  # ...
}
```

6. `nixos-rebuild` する

## rEFIndの導入
Windowsとのデュアルブート構成などになっている場合などに有用 (あと見た目)  
  
1.`refind-install` する
```bash
$ sudo refind-install
ShimSource is none
Installing rEFInd on Linux....
ESP was found at /boot using vfat

CAUTION: Your computer appears to be booted with Secure Boot, but you haven't
specified a valid shim.efi file source. Chances are you should re-run with
the --shim option. You can read more about this topic at
http://www.rodsbooks.com/refind/secureboot.html.

Do you want to proceed with installation (Y/N)? y
OK; continuing with the installation...
Copied rEFInd binary files

Copying sample configuration file as refind.conf; edit this file to configure
rEFInd.

Creating new NVRAM entry
rEFInd is set as the default boot manager.
Creating //boot/refind_linux.conf; edit it to adjust kernel options.

Installation has completed successfully.
```

2. rEFIndのバイナリを署名する
```bash
$ sudo sbctl sign -s /boot/EFI/refind/refind_x64.efi
✓ Signed /boot/EFI/refind/refind_x64.efi
```

3. 設定の変更  

デフォルトのままだと世代数が多くなってきたときにrEFIndが死ぬ問題があるため、以下の設定を追記しておく
```bash
$ sudo nano /boot/EFI/refind/refind.conf
```

```conf
dont_scan_dirs EFI/Linux,EFI\Linux,Linux
```

4. 完成
あとは自分好みにlet'sカスタマイズ！
