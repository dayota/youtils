#!/bin/bash

# Utilitaires d'affichage réutilisables
# utils/display.sh

# Couleurs pour les messages
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export WHITE='\033[1;37m'
export GRAY='\033[0;37m'
export NC='\033[0m' # No Color

# Icônes pour améliorer l'affichage
export ICON_SUCCESS="✓"
export ICON_ERROR="✗"
export ICON_WARNING="⚠"
export ICON_INFO="ℹ"
export ICON_QUESTION="?"
export ICON_ARROW="→"
export ICON_BULLET="•"

# Fonction pour afficher un message d'information
log_info() {
    echo -e "${BLUE}[INFO]${NC} ${ICON_INFO} $1"
}

# Fonction pour afficher un message de succès
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} ${ICON_SUCCESS} $1"
}

# Fonction pour afficher un avertissement
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} ${ICON_WARNING} $1"
}

# Fonction pour afficher une erreur
log_error() {
    echo -e "${RED}[ERROR]${NC} ${ICON_ERROR} $1"
}

# Fonction pour afficher un message de debug
log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${GRAY}[DEBUG]${NC} $1"
    fi
}

# Fonction pour afficher un message personnalisé avec couleur
log_custom() {
    local color="$1"
    local icon="$2"
    local message="$3"
    echo -e "${color}${icon}${NC} $message"
}

# Fonction pour afficher un titre principal
display_title() {
    local title="$1"
    local width=${2:-60}
    
    echo ""
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "${BLUE}$(printf '%*s' $(((${#title}+$width)/2)) "$title")${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo ""
}

# Fonction pour afficher un sous-titre
display_subtitle() {
    local subtitle="$1"
    local width=${2:-40}
    
    echo ""
    echo -e "${CYAN}$(printf -- '-%.0s' $(seq 1 $width))${NC}"
    echo -e "${CYAN}$subtitle${NC}"
    echo -e "${CYAN}$(printf -- '-%.0s' $(seq 1 $width))${NC}"
}

# Fonction pour afficher une liste avec puces
display_list() {
    local items=("$@")
    for item in "${items[@]}"; do
        echo -e "   ${ICON_BULLET} $item"
    done
}

# Fonction pour afficher une liste numérotée
display_numbered_list() {
    local items=("$@")
    local counter=1
    for item in "${items[@]}"; do
        echo -e "   $counter. $item"
        ((counter++))
    done
}

# Fonction pour afficher une barre de progression simple
display_progress() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${BLUE}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%% (%d/%d)${NC}" "$percentage" "$current" "$total"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Fonction pour demander confirmation
ask_confirmation() {
    local message="$1"
    local default="${2:-N}"
    local prompt
    
    if [[ "$default" == "Y" ]]; then
        prompt="(Y/n)"
    else
        prompt="(y/N)"
    fi
    
    echo -e "${YELLOW}${ICON_QUESTION} $message $prompt: ${NC}"
    read -r response
    
    if [[ -z "$response" ]]; then
        response="$default"
    fi
    
    case "$response" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# Fonction pour afficher un message avec délai
display_with_delay() {
    local message="$1"
    local delay="${2:-2}"
    
    echo -e "$message"
    sleep "$delay"
}

# Fonction pour afficher un spinner de chargement
display_spinner() {
    local pid="$1"
    local message="${2:-Loading...}"
    local spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    
    while kill -0 "$pid" 2>/dev/null; do
        i=$(((i+1) % ${#spin_chars}))
        printf "\r${BLUE}%s${NC} %s" "${spin_chars:$i:1}" "$message"
        sleep 0.1
    done
    printf "\r"
}

# Fonction pour afficher un tableau simple
display_table() {
    local -n table_data="$1"
    local headers=("${table_data[@]:0:1}")
    local rows=("${table_data[@]:1}")
    
    # Afficher les en-têtes
    echo -e "${BLUE}${headers[*]}${NC}"
    echo -e "${BLUE}$(printf -- '-%.0s' $(seq 1 ${#headers[*]}))${NC}"
    
    # Afficher les lignes
    for row in "${rows[@]}"; do
        echo "$row"
    done
}

# Fonction pour afficher un résumé formaté
display_summary() {
    local title="$1"
    shift
    local items=("$@")
    
    echo ""
    display_title "$title"
    echo ""
    
    for item in "${items[@]}"; do
        if [[ "$item" =~ ^[[:space:]]*$ ]]; then
            echo ""
        else
            echo -e "   ${ICON_BULLET} $item"
        fi
    done
    echo ""
}

# Fonction pour afficher des informations importantes
display_important() {
    local title="$1"
    shift
    local messages=("$@")
    
    echo ""
    echo -e "${YELLOW}${ICON_WARNING} $title${NC}"
    echo -e "${YELLOW}$(printf '=%.0s' $(seq 1 ${#title}))${NC}"
    
    for message in "${messages[@]}"; do
        echo -e "${YELLOW}${ICON_ARROW} $message${NC}"
    done
    echo ""
}

# Fonction pour afficher les instructions d'utilisation
display_usage() {
    local script_name="$1"
    local description="$2"
    shift 2
    local options=("$@")
    
    display_title "USAGE: $script_name"
    echo -e "${CYAN}Description:${NC} $description"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    
    for option in "${options[@]}"; do
        echo -e "   ${ICON_BULLET} $option"
    done
    echo ""
}

# Fonction pour nettoyer l'affichage
clear_line() {
    printf "\r\033[K"
}

# Fonction pour afficher un séparateur
display_separator() {
    local width="${1:-60}"
    local char="${2:-=}"
    echo -e "${GRAY}$(printf "${char}%.0s" $(seq 1 $width))${NC}"
}

# Fonction pour afficher du texte centré
display_centered() {
    local text="$1"
    local width="${2:-$(tput cols 2>/dev/null || echo 80)}"
    local padding=$(((width - ${#text}) / 2))
    
    printf "%*s%s\n" $padding "" "$text"
}

# Fonction pour afficher un encadré
display_box() {
    local content="$1"
    local width="${2:-60}"
    local color="${3:-$BLUE}"
    
    echo -e "${color}┌$(printf '─%.0s' $(seq 1 $((width-2))))┐${NC}"
    echo -e "${color}│$(printf '%*s' $((width-2)) "$content")│${NC}"
    echo -e "${color}└$(printf '─%.0s' $(seq 1 $((width-2))))┘${NC}"
}

# Fonction pour afficher un message avec timestamp
log_with_timestamp() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    case "$level" in
        "INFO") echo -e "${BLUE}[$timestamp] [INFO]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[$timestamp] [SUCCESS]${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}[$timestamp] [WARNING]${NC} $message" ;;
        "ERROR") echo -e "${RED}[$timestamp] [ERROR]${NC} $message" ;;
        *) echo -e "${GRAY}[$timestamp] [$level]${NC} $message" ;;
    esac
}

# Fonction pour afficher un menu interactif
display_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    display_subtitle "$title"
    echo ""
    
    for i in "${!options[@]}"; do
        echo -e "   ${CYAN}$((i+1)).${NC} ${options[$i]}"
    done
    echo ""
    echo -e "${YELLOW}${ICON_QUESTION} Choisissez une option (1-${#options[@]}): ${NC}"
}

# Fonction pour vérifier si le terminal supporte les couleurs
check_color_support() {
    if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
        return 0
    else
        # Désactiver les couleurs si non supportées
        RED=''
        GREEN=''
        YELLOW=''
        BLUE=''
        CYAN=''
        MAGENTA=''
        WHITE=''
        GRAY=''
        NC=''
        return 1
    fi
}

# Initialisation automatique du support couleur
check_color_support

# Fonction pour exporter toutes les fonctions d'affichage
export_display_functions() {
    export -f log_info log_success log_warning log_error log_debug log_custom
    export -f display_title display_subtitle display_list display_numbered_list
    export -f display_progress ask_confirmation display_with_delay display_spinner
    export -f display_table display_summary display_important display_usage
    export -f clear_line display_separator display_centered display_box
    export -f log_with_timestamp display_menu check_color_support
}