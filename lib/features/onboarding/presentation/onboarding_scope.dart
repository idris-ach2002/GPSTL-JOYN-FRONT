import 'package:flutter/widgets.dart';

import 'controllers/cv_import_controller.dart';
import 'controllers/onboarding_controller.dart';

/// Garde l'état de l'onboarding et de l'import du CV pendant toute la durée
/// du parcours. Placé dans un `ShellRoute`, il survit aux allers-retours
/// entre `/candidate/onboarding` et `/candidate/onboarding/cv`.
class OnboardingScope extends StatefulWidget {
  const OnboardingScope({required this.child, super.key});

  final Widget child;

  /// Contrôleur de l'onboarding. Le widget appelant se reconstruit
  /// à chaque changement.
  static OnboardingController onboardingOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_OnboardingInherited>();
    assert(scope != null, 'Aucun OnboardingScope au-dessus de ce widget.');
    return scope!.notifier!;
  }

  /// Contrôleur de l'import du CV.
  static CvImportController cvImportOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_CvImportInherited>();
    assert(scope != null, 'Aucun OnboardingScope au-dessus de ce widget.');
    return scope!.notifier!;
  }

  @override
  State<OnboardingScope> createState() => _OnboardingScopeState();
}

class _OnboardingScopeState extends State<OnboardingScope> {
  final _onboarding = OnboardingController();
  final _cvImport = CvImportController();

  @override
  void dispose() {
    _onboarding.dispose();
    _cvImport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingInherited(
      notifier: _onboarding,
      child: _CvImportInherited(notifier: _cvImport, child: widget.child),
    );
  }
}

class _OnboardingInherited extends InheritedNotifier<OnboardingController> {
  const _OnboardingInherited({required super.notifier, required super.child});
}

class _CvImportInherited extends InheritedNotifier<CvImportController> {
  const _CvImportInherited({required super.notifier, required super.child});
}
