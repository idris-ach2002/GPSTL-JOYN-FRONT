import '../domain/student_profile_draft.dart';

/// Enregistrement du profil étudiant.
abstract interface class ProfileRepository {
  Future<void> saveProfile(StudentProfileDraft profile);
}

/// Version fictive : garde le dernier profil enregistré en mémoire.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({this.latency = const Duration(milliseconds: 700)});

  final Duration latency;

  /// Dernier profil enregistré (utile pour les tests et le débogage).
  StudentProfileDraft? lastSaved;

  @override
  Future<void> saveProfile(StudentProfileDraft profile) async {
    await Future<void>.delayed(latency);
    lastSaved = profile;
  }
}
