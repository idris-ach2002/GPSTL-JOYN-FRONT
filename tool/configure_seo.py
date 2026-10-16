#!/usr/bin/env python3
"""Add canonical URLs and sitemap only once the real public URL is known."""
import argparse
import re
from pathlib import Path
from urllib.parse import urlsplit
from xml.sax.saxutils import escape

parser = argparse.ArgumentParser()
parser.add_argument('--origin', required=True, help='Real HTTPS public root, optionally with a subdirectory')
args = parser.parse_args()
origin = args.origin.rstrip('/') + '/'
parts = urlsplit(origin)
if parts.scheme != 'https' or not parts.hostname or parts.query or parts.fragment or parts.username or parts.password or re.search(r'''[\s"'<>]''', origin):
    parser.error('An HTTPS public URL without credentials, query or fragment is required.')
root = Path(__file__).resolve().parents[1] / 'web'
pages = [('index.html', origin), ('presentation.html', origin + 'presentation.html')] + [(path.relative_to(root).as_posix(), origin + path.relative_to(root).as_posix()) for path in sorted((root / 'guides').glob('*.html'))]
for name, canonical in pages:
    path = root / name
    content = path.read_text()
    content = re.sub(r'\s*<link rel="canonical"[^>]*>', '', content)
    content = re.sub(r'\s*<meta property="og:url"[^>]*>', '', content)
    content = content.replace('</head>', f'  <link rel="canonical" href="{escape(canonical)}">\n  <meta property="og:url" content="{escape(canonical)}">\n</head>')
    path.write_text(content)
urls = [canonical for _, canonical in pages]
(root / 'sitemap.xml').write_text('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + ''.join(f'  <url><loc>{escape(url)}</loc></url>\n' for url in urls) + '</urlset>\n')
(root / 'robots.txt').write_text(f'User-agent: *\nAllow: /\nSitemap: {origin}sitemap.xml\n')
print('Canonical URLs, robots.txt and sitemap.xml configured.')
