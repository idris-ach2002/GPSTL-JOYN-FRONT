# Architecture JOYN — Web et mobile

JOYN partage les couches **data**, **domain** et les controllers, mais sépare
les interfaces web et mobile au niveau `presentation`.

```text
features/<feature>/
├── data/                       # partagé
├── domain/                     # partagé
└── presentation/
    ├── web/                    # interface navigateur / desktop
    ├── mobile/                 # interface Android / iOS
    ├── shared/                 # widgets réellement communs (si nécessaire)
    └── controllers/            # état métier partagé
```

Les anciens chemins encore présents sous `presentation/widgets`, `screens`,
etc. sont uniquement des **exports de compatibilité** afin de ne pas casser les
tests et les imports des branches déjà mergées. Le code réel est maintenant
rangé dans `web/` ou `mobile/`.

## Routage

`app/experience/experience_target.dart` choisit l'expérience :

- navigateur → web ;
- Android/iOS → mobile ;
- `--dart-define=JOYN_EXPERIENCE=mobile` force le mobile dans Chrome ;
- `--dart-define=JOYN_EXPERIENCE=web` force le web.

Deux points d'entrée facilitent le développement :

```bash
flutter run -t lib/main_mobile.dart -d chrome
flutter run -t lib/main_web.dart -d chrome
```

Le premier permet de prévisualiser la vraie application mobile dans VS Code ou
Chrome sans confondre une petite largeur web avec Android/iOS.

## Expérience mobile

Le parcours mobile ne passe jamais par la landing :

```text
Startup animé
   ↓
Connexion native
   ├── Mot de passe oublié
   └── Inscription
          ├── Candidat → création → onboarding → dashboard
          └── Entreprise → création → dashboard
```

L'interface mobile utilise ses propres compositions : hero d'authentification,
champs mobiles, cartes empilées, navigation basse et onboarding vertical.
Aucun composant marketing de la landing n'est utilisé par ces écrans.

## Expérience web

La landing, l'authentification, l'inscription, l'onboarding, le dashboard et les
pages d'information conservent leur interface web sous `presentation/web`.
