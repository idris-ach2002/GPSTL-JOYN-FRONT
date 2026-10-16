# `app_theme_data.dart`

Construit les styles typographiques, les couleurs et les états des contrôles.

[Code source](../../../lib/app/theme/app_theme_data.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `package:google_fonts/google_fonts.dart`
- `../../design_system/joyn_tokens.dart`

## Méthodes et fonctions

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `buildJoynLightTheme` | `Bibliothèque` | Construit le thème clair et les styles des contrôles à partir des jetons. | `ThemeData buildJoynLightTheme()` |

## Variables locales

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `body` | `Bibliothèque` | Base typographique Inter utilisée pour les textes de lecture. | `final body = GoogleFonts.interTextTheme().apply( bodyColor: JoynTokens.ink, displayColor: JoynTokens.ink, );` |
| `textTheme` | `Bibliothèque` | Hiérarchie de styles composée à partir du corps et des titres. | `final textTheme = body.copyWith( displayLarge: title(JoynTokens.desktopDisplay), displayMedium: title(JoynTokens.tabletDisplay), displaySmall: title(JoynTokens.mobileDisplay), headlineLarge: title(JoynTokens.heading), headlineSmall: title(JoynTokens.subheading), bodyLarge: body.bodyLarge?.copyWith( fontSize: JoynTokens.body, height: JoynTokens.textHeight, ), bodyMedium: body.bodyMedium?.copyWith( fontSize: JoynTokens.body, height: JoynTokens.textHeight, ), labelLarge: body.labelLarge?.copyWith( fontSize: JoynTokens.label, fontWeight: FontWeight.w700, ), );` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `double size` | `TextStyle title(double size)` | Taille demandée pour le dessin ou dimensions du canevas. |
| `bool filled` | `ButtonStyle button({required bool filled})` | Sélectionne le style plein plutôt que le style de bouton secondaire. |
| `states` | `Bibliothèque` | Ensemble des états visuels du bouton. |

