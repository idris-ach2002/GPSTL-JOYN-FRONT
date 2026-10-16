// Sélectionne l’implémentation Web ou neutre des opérations liées au navigateur.
//
// Référence : doc/landing/fichiers/page_metadata.md.

export 'page_metadata_stub.dart'
    if (dart.library.js_interop) 'page_metadata_web.dart';
