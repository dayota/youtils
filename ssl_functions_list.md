# Fonctions SSL/TLS disponibles dans ssl_certificate.sh

## Fonctions de génération de certificats

**generate_ssl_config** `<output_file> <common_name> [alt_names...]` → void  
Génère une configuration OpenSSL personnalisée avec noms alternatifs DNS/IP

**generate_private_key** `<output_file> [bits]` → void  
Génère une clé privée RSA avec permissions sécurisées (défaut: 4096 bits)

**generate_self_signed_cert** `<key_file> <cert_file> <config_file> [days]` → void  
Génère un certificat auto-signé à partir d'une clé privée et configuration

**generate_csr** `<key_file> <csr_file> <subject>` → void  
Génère une demande de certificat (Certificate Signing Request)

**sign_certificate** `<csr_file> <ca_cert> <ca_key> <output_cert> [days]` → void  
Signe un certificat avec une autorité de certification

**generate_dhparam** `<output_file> [bits]` → void  
Génère les paramètres Diffie-Hellman pour la sécurité SSL (défaut: 2048 bits)

## Fonctions de gestion complète

**generate_server_certificate** `<ssl_dir> <common_name> [alt_names...]` → 0/1  
Génère un certificat serveur complet (clé + certificat auto-signé)

**generate_client_certificate** `<ssl_dir> <client_name> [server_cert] [server_key]` → 0/1  
Génère un certificat client signé par le serveur

**generate_complete_ssl_setup** `<ssl_dir> <common_name> [alt_names...]` → 0/1  
Génère un ensemble complet SSL (serveur + client + paramètres DH)

## Fonctions de validation et vérification

**validate_certificate** `<cert_file>` → 0/1  
Vérifie qu'un certificat est valide et non expiré

**validate_key_cert_pair** `<key_file> <cert_file>` → 0/1  
Vérifie qu'une clé privée correspond à un certificat

**display_certificate_info** `<cert_file>` → void  
Affiche les informations principales d'un certificat (sujet, validité, etc.)

**check_certificates_expiration** `<ssl_dir> [days_warning]` → 0/1  
Vérifie l'expiration des certificats dans un répertoire (défaut: alerte 30 jours)

## Fonctions de conversion et export

**convert_pem_to_der** `<pem_file> <der_file>` → void  
Convertit un certificat du format PEM vers DER

**convert_der_to_pem** `<der_file> <pem_file>` → void  
Convertit un certificat du format DER vers PEM

**create_p12_bundle** `<key_file> <cert_file> <p12_file> <password>` → void  
Crée un fichier PKCS#12 à partir d'une clé et d'un certificat

## Fonctions utilitaires

**secure_ssl_permissions** `<ssl_dir>` → 0/1  
Sécurise les permissions des fichiers SSL (600 pour clés, 644 pour certificats)

**cleanup_ssl_temp_files** `<ssl_dir>` → 0/1  
Nettoie les fichiers temporaires SSL (.csr, .conf, .srl)

**generate_ssl_report** `<ssl_dir> [output_file]` → void  
Génère un rapport détaillé des certificats présents dans un répertoire

## Fonctions de gestion du module

**export_ssl_functions** `void` → void  
Exporte toutes les fonctions SSL pour utilisation dans d'autres scripts

**test_ssl_functions** `void` → void  
Lance une suite de tests pour valider le bon fonctionnement des fonctions SSL

## Configuration par défaut

- **SSL_DEFAULT_BITS**: 4096 (taille des clés RSA)
- **SSL_DEFAULT_DAYS**: 365 (durée de validité des certificats)
- **SSL_DH_BITS**: 2048 (taille des paramètres Diffie-Hellman)
- **SSL_CLIENT_BITS**: 2048 (taille des clés client)

## Usage typique

```bash
# Sourcer le fichier pour charger les fonctions
source ssl_certificate.sh

# Génération complète d'un setup SSL
generate_complete_ssl_setup "/path/to/ssl" "mon-serveur.local" "localhost" "127.0.0.1"

# Vérification des certificats
check_certificates_expiration "/path/to/ssl" 30
```