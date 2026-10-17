import 'package:flutter/material.dart';

/// Signale qu'une action mène vers un écran pas encore développé.
void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$feature arrive bientôt.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
