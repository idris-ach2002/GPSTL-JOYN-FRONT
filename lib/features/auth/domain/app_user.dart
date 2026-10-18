import 'user_role.dart';

/// Utilisateur connecté, tel que l'application le manipule.
///
/// Indépendant du format renvoyé par le backend : c'est à l'implémentation
/// de `AuthRepository` de convertir la réponse de l'API en [AppUser].
class AppUser {
  const AppUser({required this.id, required this.email, required this.role});

  final String id;
  final String email;
  final UserRole role;
}
