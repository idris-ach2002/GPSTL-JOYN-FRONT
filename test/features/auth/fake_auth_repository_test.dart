import 'package:flutter_test/flutter_test.dart';

import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/domain/auth_exception.dart';
import 'package:joyn_front/features/auth/domain/user_role.dart';

Matcher throwsAuthError(AuthErrorCode code) =>
    throwsA(isA<AuthException>().having((e) => e.code, 'code', code));

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository(latency: Duration.zero));

  test('connecte un compte de démo', () async {
    final user = await repository.signIn(
      email: 'Recruteur@joyn.fr',
      password: FakeAuthRepository.demoPassword,
    );

    expect(user.role, UserRole.company);
    expect(await repository.currentUser(), user);
  });

  test('refuse un mauvais mot de passe', () {
    expect(
      repository.signIn(email: 'etudiant@joyn.fr', password: 'faux1234'),
      throwsAuthError(AuthErrorCode.invalidCredentials),
    );
  });

  test('crée un compte puis permet de s’y reconnecter', () async {
    await repository.signUp(
      email: 'nouveau@joyn.fr',
      password: 'Secret123',
      role: UserRole.student,
    );
    await repository.signOut();
    expect(await repository.currentUser(), isNull);

    final user = await repository.signIn(
      email: 'nouveau@joyn.fr',
      password: 'Secret123',
    );
    expect(user.role, UserRole.student);
  });

  test('refuse une inscription avec un e-mail déjà utilisé', () {
    expect(
      repository.signUp(
        email: 'etudiant@joyn.fr',
        password: 'Secret123',
        role: UserRole.student,
      ),
      throwsAuthError(AuthErrorCode.emailAlreadyInUse),
    );
  });
}
