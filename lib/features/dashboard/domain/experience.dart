/// Une étape du parcours du candidat (stage, emploi, mission…).
class Experience {
  const Experience({
    this.title,
    this.organization,
    this.period,
    this.description,
  });

  /// Intitulé (ex. « Stage développeuse web »).
  final String? title;

  /// Entreprise ou établissement.
  final String? organization;

  /// Période déjà mise en forme (ex. « juin-juillet 2026 · 3 mois »).
  final String? period;
  final String? description;
}
