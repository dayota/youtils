Fonctions de validation et utilitaires
validate_password_length (length) → 0|1 - Valide qu'une longueur de mot de passe est comprise entre 8 et 128 caractères
export_password_functions () → void - Exporte toutes les fonctions de génération de mots de passe dans l'environnement
test_password_generators () → void - Teste et affiche des exemples de tous les générateurs de mots de passe
Fonctions de génération de mots de passe
generate_simple_password (length=32) → string - Génère un mot de passe simple en base64 avec caractères alphanumériques
generate_alphanumeric_password (length=32) → string - Génère un mot de passe avec uniquement des lettres et chiffres
generate_complex_password (length=32, use_safe_special=false) → string - Génère un mot de passe complexe avec caractères spéciaux, garantit au moins un caractère de chaque type
generate_pattern_password (pattern, length=32) → string - Génère un mot de passe selon un pattern spécifique (ULNS, ULN, HEX)
generate_passphrase (word_count=4, separator="-", add_numbers=true) → string - Génère une phrase de passe avec des mots anglais séparés
generate_password_for_service (service, custom_length) → string - Génère un mot de passe adapté à un service spécifique (database, api, user, admin, etc.)
generate_best_password (length=32, count=5, service="default") → string - Génère plusieurs mots de passe et retourne le plus fort selon les critères de sécurité
Fonctions de validation et hachage
validate_password_strength (password, min_length=12) → string - Évalue la force d'un mot de passe et retourne score, niveau et recommandations
hash_password (password, algorithm="sha256", salt) → string - Génère un hash sécurisé du mot de passe avec différents algorithmes (md5, sha1, sha256, sha512, bcrypt)
Le script propose également des constantes prédéfinies pour les jeux de caractères (majuscules, minuscules, chiffres, caractères spéciaux) et les paramètres par défaut.