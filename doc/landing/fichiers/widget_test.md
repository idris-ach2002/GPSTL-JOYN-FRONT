# `widget_test.dart`

[Code source](../../../test/widget_test.dart) · [Développement et tests](../developpement.md) · [Référence](../reference.md)

## Préparation

`GoogleFonts.config.allowRuntimeFetching` est désactivé pour utiliser les polices embarquées. `setViewport` règle la taille physique de la vue et le ratio de pixels ; ses restaurations sont enregistrées avec `addTearDown`. `mount` crée un `MaterialApp` thémé dans lequel le composant peut défiler. `activate` rend un texte visible, le sélectionne et attend la fin des animations.

## Scénarios

- `editorial ink titles retain contrast in every text-button state`
- `mobile chapters open on demand and preserve the local profile`
- `mobile menu has a category level and a back path`
- `connection interface never simulates an authenticated account`
- `desktop hover menu switches groups and follows a real target`
- `menu Escape closes the panel and restores its trigger focus`
- `favorites, empty results and resetting filters preserve local choices`
- `profile clear and validation cannot publish an empty preview`
- `meeting simulation reveals and resets the conversation`
- `menu siblings use distinct pictograms including shared destinations`
- `CV explanation presents the product without a fabricated score`
- `FAQ searches accents and resets pagination after filtering`
- `carousel buttons reach each endpoint without looping`
- `landing has no layout exceptions at width $width`

Le scénario responsive est instancié pour 320, 390, 768, 1024 et 1440 pixels. La suite comporte ainsi dix-huit tests. Le compteur d’un carrousel est vérifié à chaque extrémité ; les favoris et l’aperçu restent contrôlés après une réinitialisation ; les tests du menu placent explicitement le focus avant les touches clavier.

## Variables et paramètres

| Déclaration | Usage |
| --- | --- |
| `WidgetTester tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `Size size` | Dimensions logiques demandées ; le ratio de pixels vaut un. |
| `WidgetTester tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `Widget child` | Composant monté dans la zone défilable. |
| `Size size` | Dimensions logiques demandées ; le ratio de pixels vaut un. |
| `WidgetTester tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `String text` | Libellé à rendre visible puis à activer. |
| `final target = find.text(text);` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `final theme=AppTheme.light;` | Thème JOYN employé pour les assertions de style. |
| `final style=theme.textButtonTheme.style!;` | Style de bouton dont les états sont vérifiés. |
| `final background=Color.alphaBlend(style.backgroundColor!.resolve(states)!,JoynTokens.paper);` | Fond effectivement composé sur le blanc de référence. |
| `final ratio=(background.computeLuminance()+.05)/(JoynTokens.ink.computeLuminance()+.05);` | Rapport de luminance utilisé pour vérifier le contraste du texte. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `final chapter=find.byKey(const ValueKey('chapter-parcours'));` | Commande d’ouverture du chapitre contenant le profil. |
| `final name=find.byType(TextFormField).first;` | Champ de prénom dont le contenu doit survivre au repli du chapitre. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `String? destination;` | Dernière cible reçue depuis le callback de navigation. |
| `value` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `String? destination;` | Dernière cible reçue depuis le callback de navigation. |
| `target` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `final desktopTrigger = find.byKey(const ValueKey('nav-group-1'));` | Entrée desktop dont la présence garantit le bon mode responsive. |
| `final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);` | Pointeur de souris utilisé pour ouvrir et changer de panneau. |
| `final skillLink = find.byKey(const ValueKey('mega-profil-Profil et CV'));` | Lien vers le profil examiné après changement de panneau. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `_` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `final trigger = find.byKey(const ValueKey('nav-group-0'));` | Bouton dont le retour de focus est vérifié. |
| `final triggerFocus = tester.widget<TextButton>(trigger).focusNode!;` | Nœud de focus du bouton déclencheur. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `final save = find.byKey(const ValueKey('save-offer-1'));` | Commande d’enregistrement de la première offre. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `widget` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `final kinds=group.links.map((item) => symbolFor(item.label)).toList();` | Dessins résolus pour vérifier leur distinction dans un groupe. |
| `item` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
| `final next = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'SUIVANT'));` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `final previousContext = tester.element(find.text('PRÉCÉDENT'));` | Valeur de préparation ou d’assertion du scénario indiqué par sa déclaration. |
| `final previousFocus = Focus.of(previousContext);` | Nœud explicitement focalisé avant le raccourci du carrousel. |
| `tester` | Pilote le montage, les gestes, les touches et les assertions de widgets. |
