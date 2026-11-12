# JOYN — Studio recruteur V2

Cette livraison poursuit la branche `feat/espace-recruteur` à partir du commit `4a888dd` déjà appliqué.
Elle conserve les parcours et les dépôts de la V1 et ajoute des outils de travail, des préférences
persistantes et une adaptation des surfaces au mode sombre.

## Ce qui a changé, onglet par onglet

| Espace | Fonctionnalités ajoutées | Usage concret |
| --- | --- | --- |
| Dashboard | Modules masquables/réaffichables, export CSV des indicateurs et de la tendance de la période, accès aux actions, entretiens et pipeline | Masquer temporairement les graphiques pour se concentrer sur les relances |
| Offres | Duplication en brouillon, modèles réutilisables, création vide ou préremplie depuis un modèle, valeurs par défaut, actions groupées et export de la vue filtrée | Dupliquer une alternance sans republier automatiquement l’original |
| Talents | Recherches enregistrées, comparaison de trois profils, notes privées, prochaines actions, préparation d’entretien et suivi dans un pipeline personnel | Comparer formation, expérience, compétences et disponibilité avant l’échange |
| Profil | Identité, entreprise, marque employeur, avantages, valeurs, processus de recrutement, trois ambiances de couverture, aperçu et complétude | Préparer une présentation que les candidats peuvent comprendre rapidement |
| Notifications | Recherche, catégories, non lues, épingles, archives restaurables, report de 24 h, sélection multiple et suppression confirmée | Mettre de côté une information sans la supprimer définitivement |
| Messages | Conversations prioritaires/archivées, modèles avec `{prenom}`, signature visible avant envoi, recherche dans l’échange, copie, brouillons et accès aux notes/relances/entretiens | Préparer un premier contact personnalisé puis suivre sa prochaine action |
| Paramètres | Sept rubriques, navigation par sous-menus sur mobile, menu latéral sur écran large, apparence et confort, notifications, recrutement, messagerie, confidentialité, compte et aide | Choisir le mode sombre et conserver son réglage après fermeture |
| Centre de travail | Actions avec échéance/priorité, entretiens avec contrôle des chevauchements, export ICS, suivi des talents et consultation des notes | Préparer un créneau, le confirmer par message, puis l’importer dans son calendrier |

La préparation d’un entretien n’envoie aucune invitation. Le pipeline est un suivi personnel :
changer une étape ne modifie pas automatiquement une candidature et n’envoie aucun message.
Les notes sont privées dans l’espace utilisateur ; leur accès doit être protégé côté serveur en API.
Le comparateur présente les informations du poste sans prendre de décision d’embauche.

## Apparence et usage web/mobile

- Thèmes **clair**, **sombre** et **système**, avec préférence conservée sur l’appareil.
- Accents Corail/Azur/Menthe, densité confortable/compacte, texte de 100 à 130 %, contrastes renforcés.
- Réduction des animations appliquée aux changements de thème et aux transitions des graphiques ;
  le signal de réduction des animations est aussi propagé aux composants Flutter.
- Surfaces, textes et dégradés des pages recruteur adaptés au sombre, sans filtre appliqué aux images.
- Cartes KPI qui s’ajustent au contenu et carrousels candidats dont la hauteur suit la fiche.
- Sous-menus de paramètres avec retour sur mobile ; liste de conversations et échange côte à côte
  sur grand écran, écran séparé sur petit écran.
- Recherche depuis la loupe de l’en-tête ; raccourcis `Ctrl+K` / `Cmd+K`.
  Elle couvre les pages, actions et conversations déjà chargées, pas tout le catalogue serveur.
- `Ctrl+Entrée` / `Cmd+Entrée` envoie le message depuis le champ de saisie ; Entrée garde le retour à la ligne.

Les tests de lecture à 130 % ne constituent pas une certification d’accessibilité complète.
Les autres écrans publics/candidats existants ne font pas partie de la refonte graphique du studio.

## Paramètres disponibles

1. **Apparence et confort** : thème, accent, densité, taille du texte, animations et contraste.
2. **Notifications** : e-mails, messages, matches, candidatures, offres, résumé quotidien/hebdomadaire,
   horaires calmes et aperçu du contenu. Les choix de distribution sont transmis au backend.
3. **Recrutement** : contrat, localisation et organisation du travail pour les nouvelles offres.
   Les suppressions sensibles restent confirmées.
4. **Messagerie** : signature, ajout automatique de signature, placement au dernier échange,
   création et suppression des réponses enregistrées.
5. **Confidentialité** : visibilité entreprise et masquage des aperçus de message dans le centre.
6. **Compte et sécurité** : adresse du compte, demande de réinitialisation, consultation/copie des
   données de travail, réinitialisation de l’apparence et déconnexion.
7. **Aide** : repères d’utilisation du studio.

Aucune fausse gestion d’abonnement, facturation, 2FA ou session distante n’est affichée.
Les fonctions e-mail, notifications système, contrôle d’accès et distribution des alertes reposent
sur les services du backend. Les horaires calmes ne bloquent pas la consultation manuelle du centre.

## Persistance et séparation des comptes

`shared_preferences` conserve les préférences de cet appareil. Aucun mot de passe ni jeton n’y est stocké.

En mock, les nouvelles données de travail — notes, tâches, entretiens, pipeline, comparaison,
modèles, recherches, archives et brouillons — sont enregistrées par identifiant de compte.
Le profil, les réglages, notifications et conversations du scénario mock sont également restaurés
par compte. Une écriture locale refusée restaure la version confirmée au lieu d’afficher un faux succès.
Les écritures des données de travail sont séquencées pour conserver deux modifications rapprochées.

Les offres et statuts de recommandations du dépôt mock historique restent en mémoire : ils
retrouvent leur scénario initial au redémarrage. Les modèles d’offres enregistrés dans le studio restent disponibles.
En API, ces entités sont fournies et sauvegardées par le serveur.

Les préférences d’apparence sont propres à l’appareil, pas synchronisées entre téléphone et navigateur.
La session d’authentification reste en mémoire comme en V1 : reconnexion après redémarrage complet,
pas de refresh token ni de persistance de l’option historique « Se souvenir de moi ».

## Connexion au backend

Le lanceur et le `.env` restent compatibles avec la V1. Pour préserver un `.env` déjà présent :

```bash
flutter pub get
cp -n .env.example .env
python3 scripts/run-joyn.py
```

Pour Android/iOS :

```bash
python3 scripts/run-joyn.py run -d NOM_APPAREIL -t lib/main_mobile.dart
```

Le nouveau contrat est décrit dans `CONTRAT_API_STUDIO_V2.md`. Le backend doit ajouter le point
d’accès aux données de travail et accepter les champs de profil/préférences supplémentaires.
Le simple changement d’URL fonctionne si le serveur respecte les contrats V1 et V2 ; aucune API
backend réelle n’a été fournie pour le vérifier. Une erreur API ne déclenche pas de repli mock.

Le chat reste basé sur HTTP avec actualisation périodique : pas de WebSocket, pièces jointes,
statut de présence ou accusé de lecture destinataire. « Envoyé » signifie que le serveur a confirmé le message.
L’export ICS crée un fichier personnel ; il ne programme pas d’alerte système et n’envoie pas d’invitation.

## Recette conseillée

- Se connecter avec `recruteur@joyn.fr` / `Joyn2026` en mock.
- Ouvrir Paramètres > Apparence, activer Sombre, puis vérifier les autres onglets et redémarrer l’app.
- Dans Notifications, épingler, reporter, archiver, restaurer et marquer non lue une actualité.
- Créer une signature et une réponse enregistrée, puis les utiliser dans une conversation.
- Quitter une conversation et vérifier le brouillon en y revenant.
- Depuis une fiche talent, ajouter une note, une relance et une étape de pipeline ; comparer trois profils.
- Dupliquer une offre et vérifier le statut Brouillon ; créer un modèle puis démarrer une offre depuis ce modèle.
- Vérifier les actions groupées sur une sélection de démonstration ; contrôler les succès et échecs par offre.
- Créer deux entretiens qui se chevauchent et vérifier la confirmation ; exporter un ICS et l’importer dans son calendrier.
- En API, vérifier droits, validation des payloads, erreurs, concurrence et persistance serveur.

Les résultats des contrôles exécutés sont dans `VALIDATION_STUDIO_V2.md`.

## Repères de conception consultés

Ces références ont servi de repères d’interaction, sans copie de leur interface :

- Apple, « Ajuster la luminosité de l’écran et les couleurs sur l’iPhone », consulté le 29/10/2026 :
  https://support.apple.com/fr-fr/guide/iphone/iph60ba71065/ios
- Slack, « Use dark mode in Slack », consulté le 29/10/2026 :
  https://slack.com/intl/en-gb/help/articles/360019434914-Use-dark-mode-in-Slack
- Slack, « Adjust your sidebar preferences », consulté le 29/10/2026 :
  https://slack.com/help/articles/212596808-Adjust-your-sidebar-preferences
- LinkedIn Recruiter, « Visibility of recruiting activity on a candidate’s profile », consulté le 29/10/2026 :
  https://www.linkedin.com/help/recruiter/answer/a404494
