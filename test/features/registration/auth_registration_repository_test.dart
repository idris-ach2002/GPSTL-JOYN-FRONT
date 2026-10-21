import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/domain/user_role.dart';
import 'package:joyn_front/features/registration/data/auth_registration_repository.dart';
import 'package:joyn_front/features/registration/data/mock_registration_repository.dart';
import 'package:joyn_front/features/registration/domain/student_account_draft.dart';

void main() {
  test('l’inscription étudiant ouvre une session dans le dépôt auth', () async {
    final auth = FakeAuthRepository(latency: Duration.zero);
    final repository = AuthRegistrationRepository(
      auth,
      companyLookupRepository: MockRegistrationRepository(
        latency: Duration.zero,
      ),
    );

    await repository.createStudentAccount(
      const StudentAccountDraft(
        firstName: 'Alex',
        lastName: 'Dupont',
        email: 'alex.dupont@etu.example.fr',
        password: 'Secret123',
        acceptedTerms: true,
        weeklyDigest: false,
      ),
    );

    final user = await auth.currentUser();
    expect(user, isNotNull);
    expect(user!.email, 'alex.dupont@etu.example.fr');
    expect(user.role, UserRole.student);
  });
}
