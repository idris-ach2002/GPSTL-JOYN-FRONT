import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/profile/data/fake_profile_repository.dart';
import 'package:joyn_front/features/profile/data/profile_repository.dart';
import 'package:joyn_front/features/profile/domain/student_profile.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_controller.dart';

class _FailingRepository implements ProfileRepository {
  @override
  Future<StudentProfile> fetchProfile() async =>
      throw const ProfileException('Serveur indisponible.');

  @override
  Future<StudentProfile> saveProfile(StudentProfile profile) async => profile;
}

void main() {
  test('le profil est chargé', () async {
    final controller = ProfileController(
      FakeProfileRepository(latency: Duration.zero),
    );
    await controller.load();
    expect(controller.status, ProfileLoadStatus.ready);
    expect(controller.profile?.fullName, 'Ariel Benatsi');
    expect(controller.completion.percent, 100);
    controller.dispose();
  });

  test('une erreur du dépôt est affichée', () async {
    final controller = ProfileController(_FailingRepository());
    await controller.load();
    expect(controller.status, ProfileLoadStatus.error);
    expect(controller.error, 'Serveur indisponible.');
    controller.dispose();
  });
}
