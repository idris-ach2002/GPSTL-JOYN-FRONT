import 'package:flutter/foundation.dart';

import '../../core/responsive/app_breakpoints.dart';

/// Expérience de présentation active.
///
/// - Android/iOS : mobile.
/// - main_web.dart : web forcé.
/// - main_mobile.dart : mobile forcé.
/// - main.dart sur Chrome/web-server : choix selon la largeur du viewport.
enum ExperienceTarget { web, mobile }

abstract final class ExperienceResolver {
  static const String _override = String.fromEnvironment('JOYN_EXPERIENCE');

  static ExperienceTarget forWebWidth(double logicalWidth) {
    return logicalWidth <= AppBreakpoints.mobile
        ? ExperienceTarget.mobile
        : ExperienceTarget.web;
  }

  static ExperienceTarget resolve({bool? webOverride, double? logicalWidth}) {
    if (webOverride != null) {
      return webOverride ? ExperienceTarget.web : ExperienceTarget.mobile;
    }

    if (_override == 'mobile') return ExperienceTarget.mobile;
    if (_override == 'web') return ExperienceTarget.web;

    if (!kIsWeb) return ExperienceTarget.mobile;

    if (logicalWidth != null) return forWebWidth(logicalWidth);

    return ExperienceTarget.web;
  }
}
