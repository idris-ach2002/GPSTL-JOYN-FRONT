import 'package:provider/provider.dart';

import '../data/cv_repository.dart';
import '../data/profile_repository.dart';

import 'package:flutter/material.dart';

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
    final scope = context
        .dependOnInheritedWidgetOfExactType<_CvImportInherited>();
    assert(scope != null, 'Aucun OnboardingScope au-dessus de ce widget.');
    return scope!.notifier!;
  }

  @override
  State<OnboardingScope> createState() => _OnboardingScopeState();
}

class _OnboardingScopeState extends State<OnboardingScope> {
  late final OnboardingController _onboarding;
  late final CvImportController _cvImport;
  @override
  void initState() {
    super.initState();
    _onboarding = OnboardingController(
      repository: context.read<ProfileRepository?>(),
    );
    _cvImport = CvImportController(repository: context.read<CvRepository?>());
  }

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
      child: _CvImportInherited(
        notifier: _cvImport,
        child: AnimatedBuilder(
          animation: _onboarding,
          builder: (context, _) => Column(
            children: [
              if (_onboarding.saveError != null)
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_onboarding.saveError!),
                    ),
                  ),
                ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingInherited extends InheritedNotifier<OnboardingController> {
  const _OnboardingInherited({required super.notifier, required super.child});
}

class _CvImportInherited extends InheritedNotifier<CvImportController> {
  const _CvImportInherited({required super.notifier, required super.child});
}
