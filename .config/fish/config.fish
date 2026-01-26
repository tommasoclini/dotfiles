if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings
    function fish_greeting
    end
    function fish_mode_prompt
    end
end

zoxide init fish | source

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias nv "nvim"
