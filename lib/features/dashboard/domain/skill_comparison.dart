/// Position du niveau du candidat par rapport à celui demandé par l'offre.
enum SkillStatus {
  exceeds('Dépasse'),
  meets('Conforme'),
  toTrain('À former');

  const SkillStatus(this.label);

  /// Libellé affiché dans le badge.
  final String label;
}

/// Une ligne du tableau « Compétences vs. votre offre ».
///
/// Tous les champs sont optionnels : `null` = pas encore fourni par le backend.
class SkillComparison {
  const SkillComparison({
    this.name,
    this.requiredLevel,
    this.candidateLevel,
    this.status,
  });

  final String? name;

  /// Niveau exigé par l'offre (ex. « Intermédiaire »).
  final String? requiredLevel;

  /// Niveau du candidat (ex. « Avancé »).
  final String? candidateLevel;
  final SkillStatus? status;
}
