# Fonctions d'affichage - display.sh

## Fonctions de logging

- **log_info(message)** - Affiche un message d'information avec icône et couleur bleue
- **log_success(message)** - Affiche un message de succès avec icône et couleur verte
- **log_warning(message)** - Affiche un avertissement avec icône et couleur jaune
- **log_error(message)** - Affiche une erreur avec icône et couleur rouge
- **log_debug(message)** - Affiche un message de debug (seulement si DEBUG=true)
- **log_custom(color, icon, message)** - Affiche un message personnalisé avec couleur et icône spécifiés
- **log_with_timestamp(level, message)** - Affiche un message avec horodatage selon le niveau spécifié

## Fonctions d'affichage de contenu

- **display_title(title, [width])** - Affiche un titre principal encadré (largeur par défaut: 60)
- **display_subtitle(subtitle, [width])** - Affiche un sous-titre avec séparateurs (largeur par défaut: 40)
- **display_list(items...)** - Affiche une liste à puces des éléments fournis
- **display_numbered_list(items...)** - Affiche une liste numérotée des éléments fournis
- **display_table(table_data_ref)** - Affiche un tableau simple à partir d'un tableau référencé
- **display_summary(title, items...)** - Affiche un résumé formaté avec titre et liste d'éléments
- **display_important(title, messages...)** - Affiche des informations importantes en surbrillance jaune
- **display_usage(script_name, description, options...)** - Affiche les instructions d'utilisation d'un script
- **display_menu(title, options...)** - Affiche un menu interactif numéroté

## Fonctions de mise en forme

- **display_separator([width], [char])** - Affiche un séparateur (largeur: 60, caractère: =)
- **display_centered(text, [width])** - Affiche du texte centré (largeur par défaut: largeur terminal)
- **display_box(content, [width], [color])** - Affiche du contenu dans un encadré (largeur: 60, couleur: bleue)

## Fonctions interactives

- **ask_confirmation(message, [default])** - Demande confirmation à l'utilisateur (retour: 0=oui, 1=non)
- **display_with_delay(message, [delay])** - Affiche un message avec délai d'attente (délai par défaut: 2s)
- **display_spinner(pid, [message])** - Affiche un spinner de chargement pendant qu'un processus s'exécute
- **display_progress(current, total)** - Affiche une barre de progression avec pourcentage

## Fonctions utilitaires

- **clear_line()** - Efface la ligne courante du terminal
- **check_color_support()** - Vérifie si le terminal supporte les couleurs (retour: 0=oui, 1=non)
- **export_display_functions()** - Exporte toutes les fonctions d'affichage pour utilisation dans d'autres scripts

## Variables exportées

### Couleurs
- RED, GREEN, YELLOW, BLUE, CYAN, MAGENTA, WHITE, GRAY, NC (No Color)

### Icônes
- ICON_SUCCESS (✓), ICON_ERROR (✗), ICON_WARNING (⚠), ICON_INFO (ℹ), ICON_QUESTION (?), ICON_ARROW (→), ICON_BULLET (•)

## Notes d'utilisation

- Le support des couleurs est automatiquement vérifié à l'initialisation
- La fonction `export_display_functions()` permet d'utiliser ces fonctions dans d'autres scripts
- Les messages de debug ne s'affichent que si la variable d'environnement DEBUG est définie à "true"
- Les largeurs par défaut s'adaptent à la taille du terminal quand c'est possible