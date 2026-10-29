import 'dart:convert';

String studioCsv(List<List<Object?>> rows) =>
    '\uFEFF${rows.map((row) => row.map((v) {
      var text = '${v ?? ''}';
      if (RegExp(r'^[=+@\-\t\r]').hasMatch(text)) text = "'$text";
      return '"${text.replaceAll('"', '""')}"';
    }).join(';')).join('\r\n')}';
String studioCalendar(List<Map<String, dynamic>> events, {DateTime? stamp}) {
  String escape(Object? v) => '${v ?? ''}'
      .replaceAll('\\', '\\\\')
      .replaceAll('\r\n', '\\n')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\n')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,');
  String date(DateTime d) =>
      '${d.toUtc().toIso8601String().split('.').first.replaceAll('-', '').replaceAll(':', '')}Z';
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//JOYN//Recruiter Studio//FR',
    'CALSCALE:GREGORIAN',
  ];
  for (final e in events) {
    final start = DateTime.tryParse('${e['start']}');
    if (start == null || e['status'] == 'cancelled') continue;
    lines.addAll([
      'BEGIN:VEVENT',
      'UID:${escape(e['id'])}@joyn.local',
      'DTSTAMP:${date(stamp ?? DateTime.now())}',
      'DTSTART:${date(start)}',
      'DTEND:${date(start.add(Duration(minutes: (e['duration'] as num? ?? 30).toInt())))}',
      'SUMMARY:${escape(e['title'])}',
      'LOCATION:${escape(e['location'])}',
      'DESCRIPTION:${escape('Candidat : ${e['name']}')}',
      'END:VEVENT',
    ]);
  }
  lines.add('END:VCALENDAR');
  // Repli RFC 5545 : au plus 75 octets UTF-8 par ligne physique.
  final folded = <String>[];
  for (final line in lines) {
    var part = '';
    var bytes = 0;
    for (final rune in line.runes) {
      final character = String.fromCharCode(rune);
      final count = utf8.encode(character).length;
      if (bytes + count > 75) {
        folded.add(part);
        part = ' ';
        bytes = 1;
      }
      part += character;
      bytes += count;
    }
    folded.add(part);
  }
  return '${folded.join('\r\n')}\r\n';
}
