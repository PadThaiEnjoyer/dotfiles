# This makes the path Cyan and the arrow Green
PROMPT='%F{cyan}%~%f %F{green}→%f '

eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"

alias save-rgb='printf "%02x%02x%02x\n" $(cat /sys/class/leds/hp-wmi::zone00/red) $(cat /sys/class/leds/hp-wmi::zone00/green) $(cat /sys/class/leds/hp-wmi::zone00/blue) > ~/.config/keyboard/default_color'

# Kills sound-rgb first, then starts party-mode with music
alias rave='pkill -f sound-rgb 2>/dev/null; party-mode --music'
# Stops the rave and resets colors
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
