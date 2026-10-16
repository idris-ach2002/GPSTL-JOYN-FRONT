// Initialise Flutter, désactive le chargement distant des polices et démarre JOYN.
//
// Référence : doc/landing/fichiers/main.md.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';
import 'core/platform/page_metadata.dart';

/// Initialise les services nécessaires avant de lancer l’application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  configureWeb();
  runApp(const JoynApp());
}
