// Fournit les mêmes fonctions sans effets sur les plateformes sans navigateur Web.
//
// Référence : doc/landing.md#page_metadata_stubdart.

/// Configure les URL sans fragment sur Web ; ne produit aucun effet dans le stub.
void configureWeb() {}

/// Actualise le titre et les métadonnées de la page sur Web.
void updatePageMetadata(String audience) {}

/// Ouvre la présentation HTML à partir de l’URL de base.
void openPresentation() {}

/// Ouvre uniquement une ressource appartenant à la liste de guides autorisée.
void openResource(String target) {}
