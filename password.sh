#!/bin/bash

# Générateur de mots de passe sécurisés réutilisable
# utils/password.sh

# Configuration par défaut
export DEFAULT_PASSWORD_LENGTH=32
export MIN_PASSWORD_LENGTH=8
export MAX_PASSWORD_LENGTH=128

# Jeux de caractères
export CHARSET_UPPER="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
export CHARSET_LOWER="abcdefghijklmnopqrstuvwxyz"
export CHARSET_DIGITS="0123456789"
export CHARSET_SPECIAL="!@#$%^&*()_+-=[]{}|;:,.<>?"
export CHARSET_SAFE_SPECIAL="!@#$%^&*()_+-="
export CHARSET_ALPHANUMERIC="${CHARSET_UPPER}${CHARSET_LOWER}${CHARSET_DIGITS}"
export CHARSET_ALL="${CHARSET_ALPHANUMERIC}${CHARSET_SPECIAL}"

# Fonction pour valider la longueur du mot de passe
validate_password_length() {
    local length="$1"
    
    if [[ ! "$length" =~ ^[0-9]+$ ]]; then
        echo "Erreur: La longueur doit être un nombre entier" >&2
        return 1
    fi
    
    if [[ "$length" -lt "$MIN_PASSWORD_LENGTH" ]]; then
        echo "Erreur: La longueur minimale est de $MIN_PASSWORD_LENGTH caractères" >&2
        return 1
    fi
    
    if [[ "$length" -gt "$MAX_PASSWORD_LENGTH" ]]; then
        echo "Erreur: La longueur maximale est de $MAX_PASSWORD_LENGTH caractères" >&2
        return 1
    fi
    
    return 0
}

# Fonction pour générer un mot de passe simple (alphanumeric + base64)
generate_simple_password() {
    local length="${1:-$DEFAULT_PASSWORD_LENGTH}"
    
    if ! validate_password_length "$length"; then
        return 1
    fi
    
    # Utilise OpenSSL pour générer un mot de passe base64 sécurisé
    openssl rand -base64 $((length * 3 / 4 + 1)) | tr -d "=+/\n" | cut -c1-"$length"
}

# Fonction pour générer un mot de passe alphanumérique
generate_alphanumeric_password() {
    local length="${1:-$DEFAULT_PASSWORD_LENGTH}"
    
    if ! validate_password_length "$length"; then
        return 1
    fi
    
    local password=""
    local charset="$CHARSET_ALPHANUMERIC"
    local charset_length=${#charset}
    
    for ((i=0; i<length; i++)); do
        local random_index=$((RANDOM % charset_length))
        password+="${charset:$random_index:1}"
    done
    
    echo "$password"
}

# Fonction pour générer un mot de passe avec caractères spéciaux
generate_complex_password() {
    local length="${1:-$DEFAULT_PASSWORD_LENGTH}"
    local use_safe_special="${2:-false}"
    
    if ! validate_password_length "$length"; then
        return 1
    fi
    
    local charset="$CHARSET_ALPHANUMERIC"
    if [[ "$use_safe_special" == "true" ]]; then
        charset+="$CHARSET_SAFE_SPECIAL"
    else
        charset+="$CHARSET_SPECIAL"
    fi
    
    local password=""
    local charset_length=${#charset}
    
    # Assurer qu'il y a au moins un caractère de chaque type
    local min_upper=1
    local min_lower=1
    local min_digit=1
    local min_special=1
    
    # Générer les caractères obligatoires
    password+="${CHARSET_UPPER:$((RANDOM % ${#CHARSET_UPPER})):1}"
    password+="${CHARSET_LOWER:$((RANDOM % ${#CHARSET_LOWER})):1}"
    password+="${CHARSET_DIGITS:$((RANDOM % ${#CHARSET_DIGITS})):1}"
    
    if [[ "$use_safe_special" == "true" ]]; then
        password+="${CHARSET_SAFE_SPECIAL:$((RANDOM % ${#CHARSET_SAFE_SPECIAL})):1}"
    else
        password+="${CHARSET_SPECIAL:$((RANDOM % ${#CHARSET_SPECIAL})):1}"
    fi
    
    # Générer le reste du mot de passe
    for ((i=4; i<length; i++)); do
        local random_index=$((RANDOM % charset_length))
        password+="${charset:$random_index:1}"
    done
    
    # Mélanger les caractères pour éviter les patterns prévisibles
    echo "$password" | fold -w1 | shuf | tr -d '\n'
}

# Fonction pour générer un mot de passe avec pattern personnalisé
generate_pattern_password() {
    local pattern="$1"
    local length="${2:-$DEFAULT_PASSWORD_LENGTH}"
    
    if ! validate_password_length "$length"; then
        return 1
    fi
    
    local password=""
    local remaining_length="$length"
    
    case "$pattern" in
        "ULNS") # Upper, Lower, Number, Special
            local each_type=$((length / 4))
            local extra=$((length % 4))
            
            # Répartir équitablement les caractères
            for ((i=0; i<each_type; i++)); do
                password+="${CHARSET_UPPER:$((RANDOM % ${#CHARSET_UPPER})):1}"
                password+="${CHARSET_LOWER:$((RANDOM % ${#CHARSET_LOWER})):1}"
                password+="${CHARSET_DIGITS:$((RANDOM % ${#CHARSET_DIGITS})):1}"
                password+="${CHARSET_SAFE_SPECIAL:$((RANDOM % ${#CHARSET_SAFE_SPECIAL})):1}"
            done
            
            # Ajouter les caractères supplémentaires
            for ((i=0; i<extra; i++)); do
                password+="${CHARSET_ALPHANUMERIC:$((RANDOM % ${#CHARSET_ALPHANUMERIC})):1}"
            done
            ;;
        "ULN") # Upper, Lower, Number seulement
            password=$(generate_alphanumeric_password "$length")
            ;;
        "HEX") # Hexadécimal
            for ((i=0; i<length; i++)); do
                password+=$(printf "%x" $((RANDOM % 16)))
            done
            ;;
        *)
            echo "Pattern non supporté: $pattern" >&2
            return 1
            ;;
    esac
    
    # Mélanger le résultat
    echo "$password" | fold -w1 | shuf | tr -d '\n'
}

# Fonction pour générer un mot de passe de style passphrase
generate_passphrase() {
    local word_count="${1:-4}"
    local separator="${2:--}"
    local add_numbers="${3:-true}"
    
    # Liste de mots communs pour la passphrase (en anglais pour la sécurité)
    local words=(
        "apple" "brave" "chair" "dance" "eagle" "flame" "ghost" "house"
        "ivory" "jolly" "knife" "lemon" "mouse" "novel" "ocean" "piano"
        "queen" "river" "stone" "tiger" "ultra" "voice" "water" "youth"
        "zebra" "angle" "beach" "cloud" "dream" "earth" "field" "green"
        "happy" "image" "jewel" "lunar" "magic" "night" "orbit" "peace"
        "quiet" "rapid" "solar" "trust" "unity" "vivid" "world" "xenon"
    )
    
    local passphrase=""
    
    for ((i=0; i<word_count; i++)); do
        local word="${words[$((RANDOM % ${#words[@]}))]}"
        
        # Capitaliser aléatoirement
        if [[ $((RANDOM % 2)) -eq 0 ]]; then
            word="$(tr '[:lower:]' '[:upper:]' <<< ${word:0:1})${word:1}"
        fi
        
        passphrase+="$word"
        
        if [[ "$i" -lt $((word_count - 1)) ]]; then
            passphrase+="$separator"
        fi
    done
    
    # Ajouter des chiffres si demandé
    if [[ "$add_numbers" == "true" ]]; then
        passphrase+="$separator$((RANDOM % 9000 + 1000))"
    fi
    
    echo "$passphrase"
}

# Fonction pour générer un mot de passe pour usage spécifique
generate_password_for_service() {
    local service="$1"
    local custom_length="$2"
    
    case "$service" in
        "database"|"db"|"postgresql"|"mysql")
            generate_complex_password "${custom_length:-40}" "true"
            ;;
        "api"|"jwt"|"token")
            generate_simple_password "${custom_length:-64}"
            ;;
        "user"|"login"|"web")
            generate_complex_password "${custom_length:-16}" "true"
            ;;
        "admin"|"root"|"system")
            generate_complex_password "${custom_length:-32}" "false"
            ;;
        "temporary"|"temp"|"otp")
            generate_alphanumeric_password "${custom_length:-8}"
            ;;
        "passphrase"|"phrase")
            generate_passphrase "4" "-" "true"
            ;;
        *)
            generate_complex_password "${custom_length:-$DEFAULT_PASSWORD_LENGTH}" "true"
            ;;
    esac
}

# Fonction pour valider la force d'un mot de passe
validate_password_strength() {
    local password="$1"
    local min_length="${2:-12}"
    local score=0
    local feedback=()
    
    # Vérifier la longueur
    if [[ ${#password} -ge "$min_length" ]]; then
        ((score += 2))
    else
        feedback+=("Longueur insuffisante (minimum $min_length caractères)")
    fi
    
    # Vérifier la présence de majuscules
    if [[ "$password" =~ [A-Z] ]]; then
        ((score += 1))
    else
        feedback+=("Manque de lettres majuscules")
    fi
    
    # Vérifier la présence de minuscules
    if [[ "$password" =~ [a-z] ]]; then
        ((score += 1))
    else
        feedback+=("Manque de lettres minuscules")
    fi
    
    # Vérifier la présence de chiffres
    if [[ "$password" =~ [0-9] ]]; then
        ((score += 1))
    else
        feedback+=("Manque de chiffres")
    fi
    
    # Vérifier la présence de caractères spéciaux
    if [[ "$password" =~ [^a-zA-Z0-9] ]]; then
        ((score += 1))
    else
        feedback+=("Manque de caractères spéciaux")
    fi
    
    # Vérifier les répétitions
    if ! [[ "$password" =~ (.)\1{2,} ]]; then
        ((score += 1))
    else
        feedback+=("Contient des répétitions de caractères")
    fi
    
    # Déterminer le niveau de sécurité
    local strength=""
    case "$score" in
        [0-2]) strength="FAIBLE" ;;
        [3-4]) strength="MOYEN" ;;
        [5-6]) strength="FORT" ;;
        *) strength="TRES_FORT" ;;
    esac
    
    # Retourner le résultat
    echo "SCORE:$score:STRENGTH:$strength:FEEDBACK:${feedback[*]}"
}

# Fonction pour générer plusieurs mots de passe et choisir le meilleur
generate_best_password() {
    local length="${1:-$DEFAULT_PASSWORD_LENGTH}"
    local count="${2:-5}"
    local service="${3:-default}"
    
    local best_password=""
    local best_score=0
    
    for ((i=0; i<count; i++)); do
        local password=$(generate_password_for_service "$service" "$length")
        local validation=$(validate_password_strength "$password" "$((length * 3 / 4))")
        local score=$(echo "$validation" | cut -d: -f2)
        
        if [[ "$score" -gt "$best_score" ]]; then
            best_score="$score"
            best_password="$password"
        fi
    done
    
    echo "$best_password"
}

# Fonction pour générer un hash sécurisé d'un mot de passe
hash_password() {
    local password="$1"
    local algorithm="${2:-sha256}"
    local salt="${3:-$(openssl rand -hex 16)}"
    
    case "$algorithm" in
        "md5")
            echo -n "${password}${salt}" | md5sum | cut -d' ' -f1
            ;;
        "sha1")
            echo -n "${password}${salt}" | sha1sum | cut -d' ' -f1
            ;;
        "sha256")
            echo -n "${password}${salt}" | sha256sum | cut -d' ' -f1
            ;;
        "sha512")
            echo -n "${password}${salt}" | sha512sum | cut -d' ' -f1
            ;;
        "bcrypt")
            if command -v htpasswd >/dev/null 2>&1; then
                htpasswd -bnBC 12 "" "$password" | tr -d ':\n' | sed 's/^[^$]*\$//'
            else
                echo "bcrypt non disponible (htpasswd requis)" >&2
                return 1
            fi
            ;;
        *)
            echo "Algorithme non supporté: $algorithm" >&2
            return 1
            ;;
    esac
}

# Fonction pour exporter toutes les fonctions de génération de mots de passe
export_password_functions() {
    export -f validate_password_length generate_simple_password
    export -f generate_alphanumeric_password generate_complex_password
    export -f generate_pattern_password generate_passphrase
    export -f generate_password_for_service validate_password_strength
    export -f generate_best_password hash_password
}

# Fonction utilitaire pour tester les générateurs
test_password_generators() {
    echo "=== Test des générateurs de mots de passe ==="
    echo "Simple (32): $(generate_simple_password 32)"
    echo "Alphanumérique (24): $(generate_alphanumeric_password 24)"
    echo "Complexe (28): $(generate_complex_password 28)"
    echo "Complexe sûr (32): $(generate_complex_password 32 true)"
    echo "Pattern ULNS (20): $(generate_pattern_password ULNS 20)"
    echo "Hexadécimal (16): $(generate_pattern_password HEX 16)"
    echo "Passphrase: $(generate_passphrase 4 - true)"
    echo "Base de données: $(generate_password_for_service database 40)"
    echo "API Token: $(generate_password_for_service api 64)"
    echo "Meilleur (30): $(generate_best_password 30 3 admin)"
}