/// Type de profil choisi à l'inscription.
enum UserRole {
  student('Étudiant·e'),
  company('Entreprise'),

  /// Administrateur de la plateforme (back-office). Pas d'inscription
  /// publique : les comptes sont créés par l'équipe.
  admin('Administrateur');

  const UserRole(this.label);

  /// Libellé affiché dans l'interface.
  final String label;
}
