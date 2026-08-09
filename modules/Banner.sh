#!/bin/bash
#
# ReconFlow banner

BOLD="\e[1m"
DIM="\e[2m"
RESET="\e[0m"

C1="\e[38;5;51m"   # logo gradient: bright cyan
C2="\e[38;5;45m"
C3="\e[38;5;39m"
C4="\e[38;5;33m"
C5="\e[38;5;27m"

BORDER="\e[38;5;244m"
GREEN="\e[38;5;42m"
YELLOW="\e[38;5;220m"
RED="\e[38;5;203m"
WHITE="\e[97m"

# ---- terminal width -------------------------------------------------------
_cols=$(tput cols 2>/dev/null)
[[ "$_cols" =~ ^[0-9]+$ ]] || _cols=80
WIDTH=$(( _cols < 68 ? _cols - 4 : 64 ))
(( WIDTH < 40 )) && WIDTH=40

_hr() { printf -v _r '%*s' "$WIDTH" ''; printf '%s' "${_r// /─}"; }

_top() { printf "${BORDER}╭%s╮${RESET}\n" "$(_hr)"; }
_bot() { printf "${BORDER}╰%s╯${RESET}\n" "$(_hr)"; }
_mid() { printf "${BORDER}├%s┤${RESET}\n" "$(_hr)"; }

# prints one row inside the box; pads based on the *visible* length of the
# colored text (i.e. with the "\e[...m" sequences stripped out first)
_row() {
    local colored="$1"
    local visible pad
    visible=$(printf '%s' "$colored" | sed -E 's/\\e\[[0-9;]*m//g')
    pad=$(( WIDTH - ${#visible} - 1 ))
    (( pad < 0 )) && pad=0
    printf "${BORDER}│${RESET} %b%*s${BORDER}│${RESET}\n" "$colored" "$pad" ""
}

# ---- logo -----------------------------------------------------------------
LOGO=(
'██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗'
'██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║'
'██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║'
'██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║'
'██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║'
'╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝'
)
LOGO_COLORS=("$C1" "$C2" "$C3" "$C4" "$C5" "$C5")

logo_w=${#LOGO[0]}
logo_pad=0
(( _cols > logo_w )) && logo_pad=$(( (_cols - logo_w) / 2 ))
_lpad=$(printf '%*s' "$logo_pad" '')

echo ""
for i in "${!LOGO[@]}"; do
    printf "%s${LOGO_COLORS[$i]}%s${RESET}\n" "$_lpad" "${LOGO[$i]}"
done
echo ""

# ---- info box ---------------------------------------------------------
_top
_row "  ${BOLD}${WHITE}ReconFlow${RESET}${DIM} — Reconnaissance Automation Framework${RESET}"
_mid
_row "  ${GREEN}Author  ${RESET} ${WHITE}Hariharan C${RESET}"
_row "  ${GREEN}Version ${RESET} ${WHITE}1.0.0${RESET}"
_row "  ${GREEN}GitHub  ${RESET} ${WHITE}https://github.com/hariharan005/ReconFlow${RESET}"
_row "  ${GREEN}License ${RESET} ${WHITE}MIT${RESET}"
_mid
_row "  ${YELLOW}Purpose ${RESET} ${WHITE}Information Gathering & Asset Discovery${RESET}"
_row "  ${YELLOW}Usage   ${RESET} ${WHITE}Authorized Security Assessments Only${RESET}"
_bot
echo ""

echo -e "${RED}${BOLD} ⚠  Disclaimer${RESET}${RED}  Use this tool only on systems you own or have"
echo -e "               explicit authorization to assess.${RESET}"
echo ""
