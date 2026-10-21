/// Type de profil choisi à l'inscription.
enum UserRole {
  student('Étudiant·e'),
  company('Entreprise');

  const UserRole(this.label);

  /// Libellé affiché dans l'interface.
  final String label;
}
