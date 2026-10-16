# Intégration des services

[Sommaire](README.md) · [Pages de service](fichiers/service_screen.md)

## Produit présenté et traitements exécutés

| Sujet | Fonctionnement présenté | Ce que fait cette interface |
| --- | --- | --- |
| CV | Analyse du CV joint à la création du profil | Affiche l’explication ; n’importe ni ne traite un fichier CV |
| Recommandations | Offres correspondant au profil candidat | Affiche des explications et des données d’exemple |
| Profil | Présentation du parcours et des compétences | Valide trois champs et met à jour un aperçu en mémoire |
| Candidatures | Suivi des démarches et gestion par offre | Présente des étapes ; n’envoie aucune candidature |
| Échanges | Intérêt réciproque et premier échange | Affiche une scène illustrée ; n’expédie aucun message |
| Connexion | Accès à un espace candidat ou recruteur | Affiche un état indisponible et des champs désactivés |
| Assistance | Aide et demande d’information | Présente les guides et conserve une question reçue dans l’URL ; aucun envoi |
| Services | Fonctions par acteur | Présente les usages ; aucun abonnement ni paiement |

Cette séparation évite de considérer un changement visuel comme une opération métier enregistrée. Il n’existe pas de client HTTP ni de contrat d’API implémenté dans les fichiers de la landing.

## Propriété des données

Les tableaux d’exemples sont définis dans les sections. Les champs et favoris sont détenus par l’état de leur widget. Aucun de ces états n’est enregistré dans un compte. Le DOM et `window.location` ne sont utilisés que par l’implémentation Web des métadonnées et des liens autorisés.

La question FAQ est portée dans l’URL d’assistance. Elle peut donc être visible dans l’historique du navigateur. Ce champ sert à formuler une question de fonctionnement et ne doit pas être utilisé pour y placer un mot de passe ou le contenu d’un CV.

## Points de raccordement

Lorsqu’un service devient disponible, conserver un propriétaire clair pour la requête, sa réponse et ses états de chargement, d’absence de données et d’erreur. Les sections de présentation ne doivent pas inventer le résultat de ces opérations.

Les contrats de données, l’authentification, les règles commerciales et les règles détaillées de recommandation ne sont pas définis par cette documentation. Leur implémentation doit s’appuyer sur les interfaces retenues pour le projet.
