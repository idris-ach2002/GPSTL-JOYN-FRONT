#!/usr/bin/env python3
"""Configure les URL canoniques et le sitemap à partir de l’origine publique.

L’argument --origin doit désigner une URL HTTPS réelle. L’outil modifie les
pages HTML de web/, puis réécrit robots.txt et sitemap.xml. Aucune opération
Git ni requête réseau n’est effectuée. Voir doc/landing.md#web-et-référencement.
"""
import argparse
import re
from pathlib import Path
from urllib.parse import urlsplit
from xml.sax.saxutils import escape

# Déclare l’interface de ligne de commande et son origine obligatoire.
parser = argparse.ArgumentParser()
parser.add_argument('--origin', required=True, help='Real HTTPS public root, optionally with a subdirectory')
args = parser.parse_args()
# Normalise le séparateur final avant de composer les URL de chaque page.
origin = args.origin.rstrip('/') + '/'
# Décompose l’URL pour refuser les données étrangères à une origine publique.
parts = urlsplit(origin)
if parts.scheme != 'https' or not parts.hostname or parts.query or parts.fragment or parts.username or parts.password or re.search(r'''[\s"'<>]''', origin):
    parser.error('An HTTPS public URL without credentials, query or fragment is required.')
# Résout les ressources Web depuis le script, indépendamment du dossier courant.
root = Path(__file__).resolve().parents[1] / 'web'
# Associe chaque fichier HTML à son URL canonique, guides compris.
pages = [('index.html', origin), ('presentation.html', origin + 'presentation.html')] + [(path.relative_to(root).as_posix(), origin + path.relative_to(root).as_posix()) for path in sorted((root / 'guides').glob('*.html'))]
# Remplace les balises existantes pour ne pas les dupliquer à chaque exécution.
for name, canonical in pages:
    path = root / name
    content = path.read_text()
    content = re.sub(r'\s*<link rel="canonical"[^>]*>', '', content)
    content = re.sub(r'\s*<meta property="og:url"[^>]*>', '', content)
    content = content.replace('</head>', f'  <link rel="canonical" href="{escape(canonical)}">\n  <meta property="og:url" content="{escape(canonical)}">\n</head>')
    path.write_text(content)
# Rassemble les URL publiées avant de générer le sitemap et les règles du robot.
urls = [canonical for _, canonical in pages]
(root / 'sitemap.xml').write_text('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + ''.join(f'  <url><loc>{escape(url)}</loc></url>\n' for url in urls) + '</urlset>\n')
(root / 'robots.txt').write_text(f'User-agent: *\nAllow: /\nSitemap: {origin}sitemap.xml\n')
print('Canonical URLs, robots.txt and sitemap.xml configured.')
