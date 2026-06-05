alias ls="eza -aT -L 1 --icons --hyperlink"
alias la="eza -al --time-style iso --icons --hyperlink"
alias cat="bat"

function fish_greeting
    set_color white --dim
    echo "NixOS $(nixos-version) @ $(uname -n)"
end