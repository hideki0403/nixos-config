alias ls="eza -aT -L 1 --icons --hyperlink"
alias la="eza -al --time-style iso --icons --hyperlink"
alias cat="bat"

function fish_greeting
    set_color white --dim
    # (?<version>\d+\.\d+)\.(?<revision>\d+)\.(?<hash>[0-9a-f]+) \((?<codename>.*?)\)
    set nix_version (nixos-version | sed -E 's/([0-9]+\.[0-9]+)\.([0-9]+)\.([0-9a-f]+) \((.*)\)/\1 (\4) [\2]/')
    echo "  NixOS $nix_version"
    echo "  $(uname -n)"
end
