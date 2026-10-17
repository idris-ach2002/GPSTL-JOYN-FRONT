import 'package:flutter/foundation.dart';

/// Données saisies pour créer un compte étudiant.
@immutable
class StudentAccountDraft {
  const StudentAccountDraft({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.acceptedTerms,
    required this.weeklyDigest,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final bool acceptedTerms;

  /// L'étudiant·e veut recevoir les offres compatibles chaque semaine.
  final bool weeklyDigest;
}
