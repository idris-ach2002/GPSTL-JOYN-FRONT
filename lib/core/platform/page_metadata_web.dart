import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:web/web.dart' as web;

void configureWeb() => usePathUrlStrategy();
void updatePageMetadata(String audience) {
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

void openPresentation() {
  final base = web.document.baseURI;
  web.window.location.assign(
    Uri.parse(base).resolve('presentation.html').toString(),
  );
}

void openResource(String target) {
  const pages = {
    'presentation': 'presentation.html',
    'guide-profil': 'guides/profil.html',
    'guide-matching': 'guides/matching.html',
    'guide-entretien': 'guides/entretien.html',
  };
  final page = pages[target];
  if (page != null) {
    web.window.location.assign(
      Uri.parse(web.document.baseURI).resolve(page).toString(),
    );
  }
}
