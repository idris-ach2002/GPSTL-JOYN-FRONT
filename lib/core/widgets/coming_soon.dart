import 'package:flutter/material.dart';

/// Affiche « … sera bientôt disponible. » pour une action pas encore branchée.
void showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$feature : bientôt disponible.')));
}
