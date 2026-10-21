import 'package:flutter/foundation.dart';

/// Expérience de présentation active.
///
/// Par défaut le web reçoit l'interface web et Android/iOS l'interface mobile.
/// Pour prévisualiser l'expérience mobile depuis Chrome/VS Code :
/// `--dart-define=JOYN_EXPERIENCE=mobile`.
enum ExperienceTarget { web, mobile }

abstract final class ExperienceResolver {
  static const String _override = String.fromEnvironment('JOYN_EXPERIENCE');

  static ExperienceTarget resolve({bool? webOverride}) {
    if (webOverride != null) {
      return webOverride ? ExperienceTarget.web : ExperienceTarget.mobile;
    }
    if (_override == 'mobile') return ExperienceTarget.mobile;
    if (_override == 'web') return ExperienceTarget.web;
    return kIsWeb ? ExperienceTarget.web : ExperienceTarget.mobile;
  }
}
