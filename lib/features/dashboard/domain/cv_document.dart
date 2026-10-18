/// CV déposé par le candidat.
class CvDocument {
  const CvDocument({this.fileName, this.updatedLabel, this.url});

  /// Nom du fichier (ex. « CV_Ariel_Benatsi.pdf »).
  final String? fileName;

  /// Date de mise à jour déjà mise en forme (ex. « Mise à jour il y a 3 jours »).
  final String? updatedLabel;

  /// Lien de téléchargement.
  final String? url;
}
