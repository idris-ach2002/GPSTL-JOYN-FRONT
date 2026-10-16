import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';
import 'core/platform/page_metadata.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  configureWeb();
  runApp(const JoynApp());
}
