# --- HISTORY & OPTIONS ---
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep

# --- COMPLETION ---
zstyle :compinstall filename "~/.zshrc"
autoload -Uz compinit && compinit
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}

# --- KEYBINDS ---
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word

# --- SSH AGENT ---
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add ~/.ssh/id_ed25519 > /dev/null 2>&1

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"

# --- ALIASES ---
alias ls="ls -a --color=auto"
alias grep="grep --color=auto"
alias save-rgb='printf "%02x%02x%02x\n" $(cat /sys/class/leds/hp-wmi::zone00/red) $(cat /sys/class/leds/hp-wmi::zone00/green) $(cat /sys/class/leds/hp-wmi::zone00/blue) > ~/.config/keyboard/default_color'
alias rave='pkill -f sound-rgb 2>/dev/null; party-mode --music'
alias stop-rave='party-mode --stop'
alias rgb-help='echo "
--- MY KEYBOARD COMMANDS ---
rave      : Start Crab Rave (Music + Lights)
stop-rave : Stop everything & reset color
batt      : Check battery percentage
check-bat : Manually run battery monitor script
save-color: Save current RGB as default
set-rgb   : Give hex code to switch color or leave blank to switch to default
party-mode: Flashes lights. --smooth, --music, --stop
sound-rgb : Flash lights to music --bass --stop
"'
alias help-rgb='rgb-help'

# --- THE PROMPT (STARSHIP) ---
# Keep this last!
eval "$(starship init zsh)"
