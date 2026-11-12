import '../../../../core/utils/placeholders.dart';

/// Mises en forme des dates et compteurs de l'écran « Mes candidatures ».
abstract final class ApplicationFormatters {
  /// « Aujourd'hui », « Hier », « Il y a 3 j », « Il y a 2 sem »…
  static String relativeDay(DateTime? date, DateTime now) {
    if (date == null) return Placeholders.missing;
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(date.year, date.month, date.day)).inDays;
    if (days <= 0) return 'Aujourd’hui';
    if (days == 1) return 'Hier';
    if (days < 7) return 'Il y a $days j';
    if (days < 30) return 'Il y a ${days ~/ 7} sem';
    return 'Il y a ${days ~/ 30} mois';
  }

  /// Date courte, ex. « 12/10/2026 ».
  static String shortDate(DateTime? date) {
    if (date == null) return Placeholders.missing;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  /// « 16 candidatures · 2 entretiens cette semaine ».
  static String summary({required int applications, required int interviews}) {
    String plural(int count, String word) =>
        '$count $word${count > 1 ? 's' : ''}';
    return '${plural(applications, 'candidature')} · '
        '${plural(interviews, 'entretien')} cette semaine';
  }

  /// Deux premières lettres de l'entreprise pour la pastille (ex. « Xy »).
  static String companyInitials(String? name) {
    final text = name?.trim() ?? '';
    if (text.isEmpty) return Placeholders.missing;
    final letters = text.length < 2 ? text : text.substring(0, 2);
    return letters[0].toUpperCase() + letters.substring(1).toLowerCase();
  }
}
