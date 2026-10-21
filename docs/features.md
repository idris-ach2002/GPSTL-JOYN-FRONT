# Fonctionnalités JOYN

Le code fonctionnel est organisé sous `lib/features/`.

## Landing

**But :** présenter JOYN et orienter les visiteurs.

- cible principale : Web ;
- présente la proposition de valeur, le constat, les fonctionnalités et les offres ;
- redirige vers l'authentification et l'inscription.

Chemin principal :

```text
lib/features/landing/
```

## Auth

**But :** gérer l'entrée dans le produit.

- connexion ;
- mot de passe oublié ;
- rôle utilisateur ;
- logique d'authentification partagée ;
- interfaces Web et Mobile distinctes.

```text
lib/features/auth/
```

## Registration

**But :** créer un compte candidat ou entreprise.

- choix du type de compte ;
- inscription candidat ;
- inscription entreprise ;
- validation des données de création de compte.

```text
lib/features/registration/
```

## Onboarding

**But :** construire le profil candidat après l'inscription.

- import CV ;
- extraction / confirmation d'informations ;
- compétences ;
- formation ;
- localisation ;
- préférences.

```text
lib/features/onboarding/
```

## Dashboard

**But :** fournir l'espace principal après authentification.

- synthèse du profil ;
- informations CV / expériences / compétences ;
- présentation des matchs ;
- compositions dédiées Web et Mobile.

```text
lib/features/dashboard/
```

## Information

**But :** afficher les pages d'information publiques et les contenus liés au footer.

```text
lib/features/information/
```

## Startup

**But :** gérer l'introduction de l'application mobile.

- animation d'ouverture ;
- transition vers l'authentification ;
- aucune landing marketing dans le parcours natif mobile.

```text
lib/features/startup/
```

## Quand ajouter une nouvelle feature ?

Créer `lib/features/<feature>/` lorsqu'un ensemble possède une responsabilité fonctionnelle claire et autonome.

Éviter de créer une feature uniquement pour ranger un widget ou un écran isolé.
