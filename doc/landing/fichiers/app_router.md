# `app_router.dart`

Déclare les routes actives de la landing, de la connexion et de l’assistance.

[Code source](../../../lib/app/routing/app_router.dart) · [Index des fichiers](../reference.md) · [Architecture](../architecture.md)

## Dépendances déclarées

- `package:flutter/material.dart`
- `package:go_router/go_router.dart`
- `../../features/landing/presentation/screens/landing_screen.dart`
- `../../features/landing/presentation/screens/service_screen.dart`

## Champs, constantes et état

| Nom | Portée | Rôle | Déclaration |
| --- | --- | --- | --- |
| `appRouter` | `Bibliothèque` | Routeur réellement fourni à MaterialApp.router. | `appRouter = GoRouter( routes: [ GoRoute(path: '/connexion',builder: (context,state) => const ServiceScreen(connection: true)), GoRoute(path: '/assistance',builder: (context,state) => ServiceScreen(connection: false,topic: state.uri.queryParameters['theme'] ?? '',question: state.uri.queryParameters['question'] ?? '')), for (final audience in ['accueil', 'candidats', 'entreprises']) GoRoute( path: audience == 'accueil' ? '/' : '/$audience', builder: (context, state) => LandingScreen( key: ValueKey(state.uri.path), audience: audience, ), ), ], errorBuilder: (context, state) => Scaffold(body: Center(child: Column( mainAxisSize: MainAxisSize.min, children: [ const Text('Cette page n’existe pas.'), TextButton(onPressed: () => context.go('/'), child: const Text('REVENIR À JOYN')), ], ))), )` |

## Paramètres

Les signatures ci-dessus portent les types, paramètres requis et valeurs par défaut. Les paramètres de callbacks sont également recensés lorsqu’ils sont déclarés explicitement.

| Paramètre | Portée | Usage |
| --- | --- | --- |
| `context` | `Bibliothèque` | Contexte Flutter de l’élément en cours de construction. |
| `state` | `Bibliothèque` | État GoRouter donnant accès au chemin demandé et aux paramètres de requête. |


## Variables de parcours

Ces variables prennent successivement les éléments de la collection indiquée ; elles ne constituent pas un état conservé entre deux rendus.

| Variable | Boucle et collection |
| --- | --- |
| `audience` | `(final audience in ['accueil', 'candidats', 'entreprises'])` |
