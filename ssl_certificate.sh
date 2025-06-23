#!/bin/bash

# =============================================================================
# SSL/TLS Certificate Functions
# =============================================================================
# Fonctions réutilisables pour la génération et gestion des certificats SSL/TLS
# Peut être sourcé dans d'autres scripts pour la gestion des certificats
# =============================================================================

# Protection contre l'inclusion multiple
if [[ "${SSL_FUNCTIONS_LOADED:-}" == "true" ]]; then
    return 0
fi
readonly SSL_FUNCTIONS_LOADED=true

# =============================================================================
# Configuration SSL par défaut
# =============================================================================

readonly SSL_DEFAULT_BITS=4096
readonly SSL_DEFAULT_DAYS=365
readonly SSL_DH_BITS=2048
readonly SSL_CLIENT_BITS=2048

# =============================================================================
# Fonctions de génération de certificats
# =============================================================================

# Génère une configuration OpenSSL personnalisée
# Usage: generate_ssl_config <output_file> <common_name> [alt_names...]
generate_ssl_config() {
    local output_file="$1"
    local common_name="$2"
    shift 2
    local alt_names=("$@")
    
    cat > "${output_file}" << EOF
[req]
default_bits = ${SSL_DEFAULT_BITS}
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
C = FR
ST = Ile-de-France
L = Paris
O = Docker Services
OU = SSL Certificate
CN = ${common_name}

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
EOF
    
    # Ajout des noms alternatifs
    local dns_counter=1
    local ip_counter=1
    
    for alt_name in "${alt_names[@]}"; do
        if [[ "${alt_name}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "${alt_name}" =~ ^::1$ ]]; then
            echo "IP.${ip_counter} = ${alt_name}" >> "${output_file}"
            ((ip_counter++))
        else
            echo "DNS.${dns_counter} = ${alt_name}" >> "${output_file}"
            ((dns_counter++))
        fi
    done
}

# Génère une clé privée
# Usage: generate_private_key <output_file> [bits]
generate_private_key() {
    local output_file="$1"
    local bits="${2:-${SSL_DEFAULT_BITS}}"
    
    openssl genrsa -out "${output_file}" "${bits}"
    chmod 600 "${output_file}"
}

# Génère un certificat auto-signé
# Usage: generate_self_signed_cert <key_file> <cert_file> <config_file> [days]
generate_self_signed_cert() {
    local key_file="$1"
    local cert_file="$2"
    local config_file="$3"
    local days="${4:-${SSL_DEFAULT_DAYS}}"
    
    openssl req -new -x509 \
        -key "${key_file}" \
        -out "${cert_file}" \
        -days "${days}" \
        -config "${config_file}" \
        -extensions v3_req
    
    chmod 644 "${cert_file}"
}

# Génère une demande de certificat (CSR)
# Usage: generate_csr <key_file> <csr_file> <subject>
generate_csr() {
    local key_file="$1"
    local csr_file="$2"
    local subject="$3"
    
    openssl req -new \
        -key "${key_file}" \
        -out "${csr_file}" \
        -subj "${subject}"
}

# Signe un certificat avec une CA
# Usage: sign_certificate <csr_file> <ca_cert> <ca_key> <output_cert> [days]
sign_certificate() {
    local csr_file="$1"
    local ca_cert="$2"
    local ca_key="$3"
    local output_cert="$4"
    local days="${5:-${SSL_DEFAULT_DAYS}}"
    
    openssl x509 -req \
        -in "${csr_file}" \
        -CA "${ca_cert}" \
        -CAkey "${ca_key}" \
        -CAcreateserial \
        -out "${output_cert}" \
        -days "${days}"
    
    chmod 644 "${output_cert}"
}

# Génère les paramètres Diffie-Hellman
# Usage: generate_dhparam <output_file> [bits]
generate_dhparam() {
    local output_file="$1"
    local bits="${2:-${SSL_DH_BITS}}"
    
    openssl dhparam -out "${output_file}" "${bits}"
    chmod 644 "${output_file}"
}

# =============================================================================
# Fonctions de gestion complète des certificats
# =============================================================================

# Génère un certificat serveur complet (clé + certificat auto-signé)
# Usage: generate_server_certificate <ssl_dir> <common_name> [alt_names...]
generate_server_certificate() {
    local ssl_dir="$1"
    local common_name="$2"
    shift 2
    local alt_names=("$@")
    
    local config_file="${ssl_dir}/server.conf"
    local key_file="${ssl_dir}/server.key"
    local cert_file="${ssl_dir}/server.crt"
    
    # Ajout des noms par défaut si pas d'alternatives fournies
    if [[ ${#alt_names[@]} -eq 0 ]]; then
        alt_names=("localhost" "127.0.0.1" "::1" "${common_name}")
    fi
    
    # Génération de la configuration
    generate_ssl_config "${config_file}" "${common_name}" "${alt_names[@]}"
    
    # Génération de la clé privée
    generate_private_key "${key_file}"
    
    # Génération du certificat
    generate_self_signed_cert "${key_file}" "${cert_file}" "${config_file}"
    
    # Nettoyage
    rm -f "${config_file}"
    
    return 0
}

# Génère un certificat client signé par le serveur
# Usage: generate_client_certificate <ssl_dir> <client_name> [server_cert] [server_key]
generate_client_certificate() {
    local ssl_dir="$1"
    local client_name="$2"
    local server_cert="${3:-${ssl_dir}/server.crt}"
    local server_key="${4:-${ssl_dir}/server.key}"
    
    local client_key="${ssl_dir}/${client_name}.key"
    local client_csr="${ssl_dir}/${client_name}.csr"
    local client_cert="${ssl_dir}/${client_name}.crt"
    local client_subject="/C=FR/ST=Ile-de-France/L=Paris/O=SSL Client/CN=${client_name}"
    
    # Génération de la clé privée client
    generate_private_key "${client_key}" "${SSL_CLIENT_BITS}"
    
    # Génération de la demande de certificat
    generate_csr "${client_key}" "${client_csr}" "${client_subject}"
    
    # Signature du certificat client
    sign_certificate "${client_csr}" "${server_cert}" "${server_key}" "${client_cert}"
    
    # Nettoyage
    rm -f "${client_csr}"
    
    return 0
}

# Génère un ensemble complet de certificats SSL (serveur + client + DH)
# Usage: generate_complete_ssl_setup <ssl_dir> <common_name> [alt_names...]
generate_complete_ssl_setup() {
    local ssl_dir="$1"
    local common_name="$2"
    shift 2
    local alt_names=("$@")
    
    # Création du répertoire SSL si nécessaire
    mkdir -p "${ssl_dir}"
    chmod 750 "${ssl_dir}"
    
    # Génération du certificat serveur
    generate_server_certificate "${ssl_dir}" "${common_name}" "${alt_names[@]}"
    
    # Génération du certificat client
    generate_client_certificate "${ssl_dir}" "client"
    
    # Génération des paramètres DH
    generate_dhparam "${ssl_dir}/dhparam.pem"
    
    return 0
}

# =============================================================================
# Fonctions de validation et vérification
# =============================================================================

# Vérifie qu'un certificat est valide
# Usage: validate_certificate <cert_file>
validate_certificate() {
    local cert_file="$1"
    
    if [[ ! -f "${cert_file}" ]]; then
        return 1
    fi
    
    # Vérification de la validité du certificat
    if openssl x509 -in "${cert_file}" -noout -checkend 0 >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Vérifie qu'une clé privée correspond à un certificat
# Usage: validate_key_cert_pair <key_file> <cert_file>
validate_key_cert_pair() {
    local key_file="$1"
    local cert_file="$2"
    
    if [[ ! -f "${key_file}" ]] || [[ ! -f "${cert_file}" ]]; then
        return 1
    fi
    
    local key_modulus cert_modulus
    key_modulus=$(openssl rsa -in "${key_file}" -noout -modulus 2>/dev/null | openssl md5)
    cert_modulus=$(openssl x509 -in "${cert_file}" -noout -modulus 2>/dev/null | openssl md5)
    
    if [[ "${key_modulus}" == "${cert_modulus}" ]]; then
        return 0
    else
        return 1
    fi
}

# Affiche les informations d'un certificat
# Usage: display_certificate_info <cert_file>
display_certificate_info() {
    local cert_file="$1"
    
    if [[ ! -f "${cert_file}" ]]; then
        echo "Certificat non trouvé: ${cert_file}"
        return 1
    fi
    
    echo "=== Informations du certificat: $(basename "${cert_file}") ==="
    openssl x509 -in "${cert_file}" -noout -text | grep -E "(Subject:|Issuer:|Not Before|Not After|DNS:|IP Address:)"
    echo
}

# Vérifie l'expiration des certificats dans un répertoire
# Usage: check_certificates_expiration <ssl_dir> [days_warning]
check_certificates_expiration() {
    local ssl_dir="$1"
    local days_warning="${2:-30}"
    
    if [[ ! -d "${ssl_dir}" ]]; then
        echo "Répertoire SSL non trouvé: ${ssl_dir}"
        return 1
    fi
    
    local expired_certs=()
    local expiring_certs=()
    
    for cert_file in "${ssl_dir}"/*.crt; do
        if [[ -f "${cert_file}" ]]; then
            local cert_name
            cert_name=$(basename "${cert_file}")
            
            # Vérification expiration
            if ! openssl x509 -in "${cert_file}" -noout -checkend 0 >/dev/null 2>&1; then
                expired_certs+=("${cert_name}")
            elif ! openssl x509 -in "${cert_file}" -noout -checkend $((days_warning * 86400)) >/dev/null 2>&1; then
                expiring_certs+=("${cert_name}")
            fi
        fi
    done
    
    # Rapport
    if [[ ${#expired_certs[@]} -gt 0 ]]; then
        echo "⚠️  Certificats expirés: ${expired_certs[*]}"
    fi
    
    if [[ ${#expiring_certs[@]} -gt 0 ]]; then
        echo "⚠️  Certificats expirant dans ${days_warning} jours: ${expiring_certs[*]}"
    fi
    
    if [[ ${#expired_certs[@]} -eq 0 ]] && [[ ${#expiring_certs[@]} -eq 0 ]]; then
        echo "✅ Tous les certificats sont valides"
        return 0
    else
        return 1
    fi
}

# =============================================================================
# Fonctions de conversion et export
# =============================================================================

# Convertit un certificat au format PEM vers DER
# Usage: convert_pem_to_der <pem_file> <der_file>
convert_pem_to_der() {
    local pem_file="$1"
    local der_file="$2"
    
    openssl x509 -in "${pem_file}" -outform DER -out "${der_file}"
    chmod 644 "${der_file}"
}

# Convertit un certificat au format DER vers PEM
# Usage: convert_der_to_pem <der_file> <pem_file>
convert_der_to_pem() {
    local der_file="$1"
    local pem_file="$2"
    
    openssl x509 -in "${der_file}" -inform DER -out "${pem_file}"
    chmod 644 "${pem_file}"
}

# Crée un fichier PKCS#12 (p12) à partir d'une clé et d'un certificat
# Usage: create_p12_bundle <key_file> <cert_file> <p12_file> <password>
create_p12_bundle() {
    local key_file="$1"
    local cert_file="$2"
    local p12_file="$3"
    local password="$4"
    
    openssl pkcs12 -export \
        -inkey "${key_file}" \
        -in "${cert_file}" \
        -out "${p12_file}" \
        -password "pass:${password}"
    
    chmod 600 "${p12_file}"
}

# =============================================================================
# Fonctions utilitaires
# =============================================================================

# Sécurise les permissions des fichiers SSL
# Usage: secure_ssl_permissions <ssl_dir>
secure_ssl_permissions() {
    local ssl_dir="$1"
    
    if [[ ! -d "${ssl_dir}" ]]; then
        return 1
    fi
    
    # Permissions pour les clés privées
    find "${ssl_dir}" -name "*.key" -exec chmod 600 {} \;
    
    # Permissions pour les certificats
    find "${ssl_dir}" -name "*.crt" -exec chmod 644 {} \;
    find "${ssl_dir}" -name "*.pem" -exec chmod 644 {} \;
    
    # Permissions pour le répertoire
    chmod 750 "${ssl_dir}"
    
    return 0
}

# Nettoie les fichiers temporaires SSL
# Usage: cleanup_ssl_temp_files <ssl_dir>
cleanup_ssl_temp_files() {
    local ssl_dir="$1"
    
    if [[ ! -d "${ssl_dir}" ]]; then
        return 1
    fi
    
    # Suppression des fichiers temporaires
    find "${ssl_dir}" -name "*.csr" -delete
    find "${ssl_dir}" -name "*.conf" -delete
    find "${ssl_dir}" -name "*.srl" -delete
    
    return 0
}

# Génère un rapport de synthèse des certificats
# Usage: generate_ssl_report <ssl_dir> [output_file]
generate_ssl_report() {
    local ssl_dir="$1"
    local output_file="${2:-${ssl_dir}/ssl_report.txt}"
    
    {
        echo "=== RAPPORT SSL/TLS ==="
        echo "Généré le: $(date)"
        echo "Répertoire: ${ssl_dir}"
        echo
        
        echo "=== CERTIFICATS PRÉSENTS ==="
        for cert_file in "${ssl_dir}"/*.crt; do
            if [[ -f "${cert_file}" ]]; then
                local cert_name
                cert_name=$(basename "${cert_file}")
                echo "• ${cert_name}"
                
                local expiry_date
                expiry_date=$(openssl x509 -in "${cert_file}" -noout -enddate 2>/dev/null | cut -d= -f2)
                echo "  Expiration: ${expiry_date}"
                
                local subject
                subject=$(openssl x509 -in "${cert_file}" -noout -subject 2>/dev/null | cut -d= -f2-)
                echo "  Sujet: ${subject}"
                echo
            fi
        done
        
        echo "=== CLÉS PRIVÉES ==="
        for key_file in "${ssl_dir}"/*.key; do
            if [[ -f "${key_file}" ]]; then
                local key_name
                key_name=$(basename "${key_file}")
                echo "• ${key_name}"
                
                local key_size
                key_size=$(openssl rsa -in "${key_file}" -noout -text 2>/dev/null | grep "Private-Key" | grep -o "[0-9]\+")
                echo "  Taille: ${key_size} bits"
                echo
            fi
        done
        
        echo "=== VÉRIFICATION DES PAIRES ==="
        for cert_file in "${ssl_dir}"/*.crt; do
            if [[ -f "${cert_file}" ]]; then
                local cert_name
                cert_name=$(basename "${cert_file}" .crt)
                local key_file="${ssl_dir}/${cert_name}.key"
                
                if [[ -f "${key_file}" ]]; then
                    if validate_key_cert_pair "${key_file}" "${cert_file}"; then
                        echo "✅ ${cert_name}: Clé et certificat correspondent"
                    else
                        echo "❌ ${cert_name}: Clé et certificat ne correspondent pas"
                    fi
                fi
            fi
        done
        
    } > "${output_file}"
    
    chmod 644 "${output_file}"
    echo "Rapport généré: ${output_file}"
}

# =============================================================================
# Fonction d'export des fonctions SSL
# =============================================================================

export_ssl_functions() {
    local functions=(
        generate_ssl_config
        generate_private_key
        generate_self_signed_cert
        generate_csr
        sign_certificate
        generate_dhparam
        generate_server_certificate
        generate_client_certificate
        generate_complete_ssl_setup
        validate_certificate
        validate_key_cert_pair
        display_certificate_info
        check_certificates_expiration
        convert_pem_to_der
        convert_der_to_pem
        create_p12_bundle
        secure_ssl_permissions
        cleanup_ssl_temp_files
        generate_ssl_report
    )
    
    for func in "${functions[@]}"; do
        export -f "${func}"
    done
    
    echo "Fonctions SSL exportées: ${#functions[@]} fonctions"
}

# =============================================================================
# Fonction de test des fonctions SSL
# =============================================================================

test_ssl_functions() {
    local test_dir="/tmp/ssl_test_$"
    
    echo "=== TEST DES FONCTIONS SSL ==="
    echo "Répertoire de test: ${test_dir}"
    
    # Création du répertoire de test
    mkdir -p "${test_dir}"
    
    echo
    echo "1. Test génération certificat serveur..."
    if generate_server_certificate "${test_dir}" "test-server" "localhost" "127.0.0.1"; then
        echo "✅ Certificat serveur généré"
    else
        echo "❌ Échec génération certificat serveur"
    fi
    
    echo
    echo "2. Test génération certificat client..."
    if generate_client_certificate "${test_dir}" "test-client"; then
        echo "✅ Certificat client généré"
    else
        echo "❌ Échec génération certificat client"
    fi
    
    echo
    echo "3. Test génération paramètres DH..."
    if generate_dhparam "${test_dir}/dhparam.pem" 512; then  # 512 bits pour test rapide
        echo "✅ Paramètres DH générés"
    else
        echo "❌ Échec génération paramètres DH"
    fi
    
    echo
    echo "4. Test validation des certificats..."
    if validate_certificate "${test_dir}/server.crt"; then
        echo "✅ Certificat serveur valide"
    else
        echo "❌ Certificat serveur invalide"
    fi
    
    echo
    echo "5. Test validation paire clé/certificat..."
    if validate_key_cert_pair "${test_dir}/server.key" "${test_dir}/server.crt"; then
        echo "✅ Paire clé/certificat valide"
    else
        echo "❌ Paire clé/certificat invalide"
    fi
    
    echo
    echo "6. Test sécurisation des permissions..."
    if secure_ssl_permissions "${test_dir}"; then
        echo "✅ Permissions sécurisées"
    else
        echo "❌ Échec sécurisation permissions"
    fi
    
    echo
    echo "7. Test génération du rapport..."
    if generate_ssl_report "${test_dir}"; then
        echo "✅ Rapport généré"
    else
        echo "❌ Échec génération rapport"
    fi
    
    echo
    echo "=== NETTOYAGE ==="
    rm -rf "${test_dir}"
    echo "Répertoire de test supprimé"
    
    echo
    echo "=== TESTS TERMINÉS ==="
}