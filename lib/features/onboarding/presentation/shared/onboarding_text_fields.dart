import 'package:flutter/widgets.dart';

import '../controllers/onboarding_controller.dart';

/// Champs texte de l'onboarding, synchronisés avec [OnboardingController].
///
/// Quand le contrôleur change « de l'extérieur » (par exemple après l'import
/// du CV), les champs reprennent sa valeur. Partagé par le web et le mobile.
class OnboardingTextFields {
  final degreeTitle = TextEditingController();
  final school = TextEditingController();
  final city = TextEditingController();
  final availableFrom = TextEditingController();
  final salary = TextEditingController();

  /// Champ « Ajouter une technologie » (non lié au contrôleur).
  final newSkill = TextEditingController();

  OnboardingController? _form;

  /// À appeler dans `didChangeDependencies` avec le contrôleur courant.
  void attach(OnboardingController form) {
    if (identical(form, _form)) return;
    _form?.removeListener(_sync);
    _form = form..addListener(_sync);
    _sync();
  }

  void _sync() {
    final form = _form;
    if (form == null) return;

    void sync(TextEditingController controller, String value) {
      if (controller.text != value) controller.text = value;
    }

    sync(degreeTitle, form.degreeTitle);
    sync(school, form.school);
    sync(city, form.city);
    sync(availableFrom, form.availableFrom);
    sync(salary, form.desiredSalary);
  }

  void dispose() {
    _form?.removeListener(_sync);
    degreeTitle.dispose();
    school.dispose();
    city.dispose();
    availableFrom.dispose();
    salary.dispose();
    newSkill.dispose();
  }
}
