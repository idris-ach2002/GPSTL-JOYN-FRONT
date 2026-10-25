import '../domain/student_profile.dart';

/// Erreur affichable lors du chargement ou de l'enregistrement du profil.
class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => 'ProfileException: $message';
}

/// Accès au profil de l'étudiant·e connecté·e, indépendant du backend.
///
/// Même principe que `DashboardRepository` : pour brancher la vraie API,
/// écrire une implémentation (ex. `ApiProfileRepository`) et l'injecter dans
/// `JoynApp` à la place de `FakeProfileRepository`.
abstract interface class ProfileRepository {
  Future<StudentProfile> fetchProfile();

  /// Enregistre le profil et renvoie la version enregistrée.
  Future<StudentProfile> saveProfile(StudentProfile profile);
}
