# Documentation JOYN

La documentation du dépôt doit rester **courte, actuelle et utile au développement**.

Elle ne sert pas à conserver l'historique des anciennes livraisons, des migrations temporaires ou des recettes ponctuelles.

## À lire

- [product.md](product.md) — pourquoi JOYN existe et quel problème le produit cherche à résoudre ;
- [features.md](features.md) — les fonctionnalités principales et leur responsabilité ;
- [architecture.md](architecture.md) — comment le code est structuré entre Web, Mobile et logique partagée ;
- [workflow.md](workflow.md) — comment contribuer sans casser `main`, avec les scripts et la CI/CD.

## Règle de maintenance

Quand une feature importante évolue :

1. mettre à jour `features.md` si sa responsabilité change ;
2. mettre à jour `architecture.md` uniquement si la structure technique change ;
3. mettre à jour `workflow.md` uniquement si le processus Git/CI change.

Le README racine reste la porte d'entrée du projet.
