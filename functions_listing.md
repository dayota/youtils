# Fichier "/src/_scripts/vendors/youtils/password.sh"
- validate_password_length(length) → code de retour - Valide qu'une longueur de mot de passe est dans les limites autorisées (8-128 caractères)
- generate_simple_password([length]) → mot de passe - Génère un mot de passe simple en base64 avec OpenSSL
- generate_alphanumeric_password([length]) → mot de passe - Génère un mot de passe alphanumérique (lettres + chiffres uniquement)
- generate_complex_password([length], [use_safe_special]) → mot de passe - Génère un mot de passe complexe avec caractères spéciaux, garantit au moins un caractère de chaque type
- generate_pattern_password(pattern, [length]) → mot de passe - Génère un mot de passe selon un pattern spécifique (ULNS, ULN, HEX)
- generate_passphrase([word_count], [separator], [add_numbers]) → passphrase - Génère une phrase de passe avec des mots anglais séparés
- generate_password_for_service(service, [custom_length]) → mot de passe - Génère un mot de passe adapté à un service spécifique (database, api, user, etc.)
- validate_password_strength(password, [min_length]) → score:force:feedback - Évalue la force d'un mot de passe et retourne un score avec recommandations
- generate_best_password([length], [count], [service]) → mot de passe - Génère plusieurs mots de passe et retourne le meilleur selon le score de sécurité
- hash_password(password, [algorithm], [salt]) → hash - Génère un hash sécurisé d'un mot de passe avec différents algorithmes
- export_password_functions() → void - Exporte toutes les fonctions de génération de mots de passe
- test_password_generators() → void - Teste et affiche des exemples de tous les générateurs disponibles
# Fichier "/src/_scripts/vendors/youtils/display.sh"
- log_info(message) → void - Affiche un message d'information en bleu avec icône
- log_success(message) → void - Affiche un message de succès en vert avec icône
- log_warning(message) → void - Affiche un avertissement en jaune avec icône
- log_error(message) → void - Affiche un message d'erreur en rouge avec icône
- log_debug(message) → void - Affiche un message de debug si DEBUG=true
- log_custom(color, icon, message) → void - Affiche un message personnalisé avec couleur et icône
- display_title(title, [width]) → void - Affiche un titre principal encadré
- display_subtitle(subtitle, [width]) → void - Affiche un sous-titre avec séparateurs
- display_list(items...) → void - Affiche une liste à puces
- display_numbered_list(items...) → void - Affiche une liste numérotée
- display_progress(current, total) → void - Affiche une barre de progression
- ask_confirmation(message, [default]) → code de retour - Demande une confirmation utilisateur (Y/N)
- display_with_delay(message, [delay]) → void - Affiche un message avec délai d'attente
- display_spinner(pid, [message]) → void - Affiche un spinner de chargement pendant qu'un processus s'exécute
- display_table(table_data_ref) → void - Affiche un tableau formaté
- display_summary(title, items...) → void - Affiche un résumé formaté avec titre et liste
- display_important(title, messages...) → void - Affiche des informations importantes en surbrillance
- display_usage(script_name, description, options...) → void - Affiche l'aide d'utilisation d'un script
- clear_line() → void - Efface la ligne courante du terminal
- display_separator([width], [char]) → void - Affiche un séparateur horizontal
- display_centered(text, [width]) → void - Affiche du texte centré
- display_box(content, [width], [color]) → void - Affiche du contenu dans un encadré
- log_with_timestamp(level, message) → void - Affiche un message avec horodatage
- display_menu(title, options...) → void - Affiche un menu interactif numéroté
- check_color_support() → code de retour - Vérifie si le terminal supporte les couleurs
- export_display_functions() → void - Exporte toutes les fonctions d'affichage