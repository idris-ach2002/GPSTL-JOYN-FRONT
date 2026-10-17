// Met à jour les métadonnées et ouvre les guides dans le navigateur.
//
// Référence : doc/landing.md#page_metadata_webdart.

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:web/web.dart' as web;

/// Configure les URL sans fragment sur Web ; ne produit aucun effet dans le stub.
void configureWeb() => usePathUrlStrategy();

/// Actualise le titre et les métadonnées de la page sur Web.
void updatePageMetadata(String audience) {
  // Titre affiché dans cette composition.
  final title = switch (audience) {
    'connexion' => 'JOYN — Connexion',
    'assistance' => 'JOYN — Assistance',
    'entreprises' => 'JOYN — Des attentes de recrutement explicites',
    _ => 'JOYN — Le match avant la candidature',
  };
  web.document.title = title;
  web.document
      .querySelector('meta[name="robots"]')
      ?.setAttribute(
        'content',
        audience == 'connexion' ? 'noindex,follow' : 'index,follow',
      );
  for (final selector in [
    'meta[property="og:title"]',
    'meta[name="twitter:title"]',
  ]) {
    web.document.querySelector(selector)?.setAttribute('content', title);
  }
  web.document.getElementById('startup')?.remove();
}

/// Ouvre la présentation HTML à partir de l’URL de base.
void openPresentation() {
  // URL de base du document, utilisée pour résoudre les pages statiques.
  final base = web.document.baseURI;
  web.window.location.assign(
    Uri.parse(base).resolve('presentation.html').toString(),
  );
}

/// Ouvre uniquement une ressource appartenant à la liste de guides autorisée.
void openResource(String target) {
  // Nombre de pages de résultats, calculé par arrondi supérieur.
  const pages = {
    'presentation': 'presentation.html',
    'guide-profil': 'guides/profil.html',
    'guide-matching': 'guides/matching.html',
    'guide-entretien': 'guides/entretien.html',
  };
  // Indice de la page de résultats FAQ, à partir de zéro.
  final page = pages[target];
  if (page != null) {
    web.window.location.assign(
      Uri.parse(web.document.baseURI).resolve(page).toString(),
    );
  }
}
