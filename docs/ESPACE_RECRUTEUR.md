# Livraison espace recruteur — 29 octobre 2026

Base vérifiée par `git fetch origin main` : `4f00aa99da534e958e467b3306eb1c96264e878b`.
Branche : `feat/espace-recruteur`.
Les commits de livraison reprennent l’auteur des derniers commits du dépôt :
Idris Achabou <idris.achabou@etu.sorbonne-universite.fr>.

## Compréhension du projet

JOYN est une application Flutter avec deux présentations (web et mobile), un routeur GoRouter,
un état fourni par Provider et des interfaces de dépôts séparées des écrans.
Les modules déjà présents couvrent inscription, onboarding candidat, dashboard candidat,
offres recruteur, recommandations et statistiques recruteur. La palette, les illustrations,
les cartes d’offres et les statistiques existantes sont réutilisées.

L’audit a relevé : boutons d’en-tête sans action, onglets Messages/Plus mobiles inactifs,
absence de routes profil/notifications/paramètres/messagerie, offres et authentification
systématiquement simulées au démarrage, clients API sans jeton, aperçus candidats générés
même pour une offre reçue du serveur.

## Parcours livrés

- **Profil et entreprise** : prénom, nom, fonction, téléphone, entreprise, ville, site et présentation.
  Validation des champs obligatoires et de l’URL, sauvegarde, erreur conservant la saisie.
- **Notifications** : liste, filtre non lues, lecture individuelle/globale, suppression,
  ouverture vers les destinations recruteur autorisées.
- **Messagerie** : recherche candidat/offre, liste et détail côte à côte sur grand écran,
  navigation liste/conversation sur mobile, échanges horodatés, lecture, envoi et états d’erreur.
  Brouillons conservés lors du changement de conversation dans l’écran ouvert.
  Après un échec d’envoi, réessayer le même texte conserve le même `clientId`.
  Le serveur doit dédupliquer ce `clientId` par conversation.
- **Paramètres** : préférences de notification et visibilité, demande de réinitialisation
  de mot de passe, déconnexion avec confirmation.
- **Navigation** : accès depuis les en-têtes et depuis une fiche candidat ; bouton Contacter
  du dialogue de match ; onglets Messages/Plus des écrans mobiles ; anciennes routes
  `/messages` et `/recruiter/company` redirigées ; statistiques/édition du détail mobile.
- **Candidatures d’une offre en API** : chargement serveur, statuts En cours / Entretien / Refusé,
  accès à la conversation. Les anciens aperçus restent des données de démonstration en mock.
- **Backend** : même client HTTP et jeton Bearer pour authentification, inscription, offres,
  recommandations, statistiques et nouveaux écrans. Une réponse 401 ferme la session locale.
  Aucun repli silencieux vers des données mock quand le mode API échoue.

## Démarrer avec un fichier .env

À la racine du projet :

```bash
cp .env.example .env
python3 scripts/run-joyn.py
```

Par défaut l’URL est vide : mode démonstration. Compte : `recruteur@joyn.fr`, mot de passe : `Joyn2026`.
Pour le backend, remplacer uniquement l’URL **si le serveur respecte le contrat documenté** :

```dotenv
JOYN_DATA_MODE=auto
JOYN_API_BASE_URL=https://votre-backend.example
JOYN_API_TIMEOUT_MS=12000
```

Puis relancer le script. Pour un mobile Android :

```bash
python3 scripts/run-joyn.py run -d NOM_APPAREIL -t lib/main_mobile.dart
```

Pour le web adaptatif (bascule web/mobile selon la largeur) :

```bash
python3 scripts/run-joyn.py run -d chrome -t lib/main.dart
```

`lib/main_web.dart` force la présentation web existante ; `lib/main_mobile.dart` force le mobile.
Les nouvelles pages adaptent aussi leur composition à la largeur disponible.
Flutter ne lit pas automatiquement un fichier `.env` : le script le convertit en définitions
compilées, sans exécuter son contenu. Une modification exige un redémarrage/rebuild.
On peut aussi utiliser directement `--dart-define-from-file=config/mock.json`.
Aucune clé privée ni aucun jeton ne doit figurer dans ces fichiers : les valeurs sont publiques
après compilation web. `.env` est ignoré par Git.

En développement Android Emulator, l’hôte local est généralement accessible par `10.0.2.2`.
Sur téléphone physique, utiliser une URL accessible depuis le téléphone. Configurer CORS côté
backend pour l’origine du front, les méthodes GET/POST/PATCH/PUT/DELETE/OPTIONS et l’en-tête
Authorization. La production doit utiliser HTTPS. Android debug autorise HTTP pour une API locale ; Android release et iOS doivent utiliser HTTPS, sauf configuration de développement spécifique. La permission Internet Android release et le droit réseau client macOS sont ajoutés.

## Contrat et limites précises

Voir `CONTRAT_API_RECRUTEUR.md`. Aucun code backend ni OpenAPI backend n’a été fourni.
Les nouvelles routes sont donc un **contrat proposé et implémenté côté front**, pas des routes
serveur vérifiées. Si le backend diffère, ajuster les classes `Api*Repository` et les mappers,
plutôt que les widgets. Les routes statistiques et recommandations préexistantes sont conservées.

La session API et les données mock vivent en mémoire. Un rechargement complet nécessite une
reconnexion et réinitialise les données de démonstration. L’option historique « Se souvenir de moi »
n’apporte pas de persistance dans cette livraison. Un stockage sécurisé natif ou une session
serveur avec cookies HttpOnly/refresh doit être défini avec le backend avant de l’activer.
Il n’y a pas de renouvellement automatique de jeton.

La messagerie API utilise une actualisation toutes les dix secondes lorsque l’application
est active, et un bouton Actualiser. Elle n’utilise pas WebSocket, n’envoie pas de pièces jointes,
ne simule pas la présence en ligne et ne prétend pas fournir de notifications push système.
Les réglages d’alertes sont sauvegardés ; leur distribution e-mail/push est une responsabilité serveur.
La page candidat existante et l’onboarding candidat restent hors du branchement API de ce lot.
Le mock est un scénario de démonstration partagé par les comptes simulés du même lancement.

Le POST offre conserve le mapper existant : l’entreprise est déduite du recruteur par le serveur,
`company_id` n’est pas envoyé. Si la sélection multi-entreprises doit être effective en API,
le backend doit accepter cet identifiant et `JobOfferApiMapper` doit l’ajouter.
Les listes API sont consommées depuis un tableau, `items`, `content`, ou l’enveloppe `data`.
Les nouvelles listes ne parcourent pas automatiquement toutes les pages d’une API paginée :
le serveur doit fournir la liste exploitable, ou un adaptateur de pagination doit être ajouté.

## Recette à effectuer sur ta machine

1. Se connecter en recruteur, ouvrir les quatre nouveaux écrans depuis l’en-tête et le mobile.
2. Modifier le prénom dans Profil, enregistrer, revenir au dashboard et vérifier le prénom.
3. Lire puis supprimer une notification, vérifier le filtre non lues.
4. Ouvrir un candidat, cliquer Contacter, écrire, envoyer, revenir à la liste puis à la conversation.
5. Modifier une préférence, enregistrer, changer d’écran puis revenir.
6. Tester création, édition, clôture et suppression d’une offre.
7. En API, vérifier les payloads dans l’onglet Réseau et les droits côté serveur ; couper le backend
   puis réessayer ; provoquer un 401 pour vérifier le retour à la connexion.
8. Sur émulateur/appareil, vérifier le clavier, le bouton retour et les zones système.

Les contrôles automatisés et leur résultat exact figurent dans `VALIDATION_RECRUTEUR.md`.

## Appliquer le ZIP en conservant les commits

Après extraction de l’archive, utiliser `appliquer-joyn.sh` à sa racine :

```bash
bash /chemin/JOYN-espace-recruteur/appliquer-joyn.sh /chemin/GPSTL-JOYN-FRONT
```

L’importeur utilise le bundle Git pour recréer/avancer `feat/espace-recruteur` avec tous les commits.
Il vérifie l’absence de modifications locales et refuse d’écraser une branche divergente.
Il ne modifie pas ta configuration d’auteur Git et ne pousse rien sur GitHub.
La synchronisation correspond à l’état d’origin/main récupéré lors de la préparation ; si main
évolue ensuite, le script peut demander une intégration de ses nouveaux commits.

Pour une copie de fichiers seule, la commande est `rsync -av` (pas `git sync -av`) :

```bash
rsync -av --exclude='.git/' /chemin/JOYN-espace-recruteur/GPSTL-JOYN-FRONT/ /chemin/ton-depot/
```

Cette seconde méthode copie le code mais ne transporte pas les commits. Pour tester précisément
la livraison avec son historique, utiliser l’importeur Git. Ne jamais copier un dossier `.git`
par-dessus celui du projet existant.
