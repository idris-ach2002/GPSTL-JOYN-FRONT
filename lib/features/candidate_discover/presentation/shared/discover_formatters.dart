import 'package:flutter/material.dart';

import '../../domain/recommended_offer.dart';

/// Pastilles d'informations pratiques d'une offre (lieu, rythme, télétravail).
List<(IconData, String)> offerFacts(RecommendedOffer offer) => [
  if (offer.location.isNotEmpty)
    (
      Icons.location_on_outlined,
      offer.commuteMinutes == null
          ? offer.location
          : '${offer.location} · ${offer.commuteMinutes} min',
    ),
  if (offer.rhythm.isNotEmpty) (Icons.calendar_today_outlined, offer.rhythm),
  if (offer.remoteDays != null && offer.remoteDays! > 0)
    (Icons.laptop_mac_outlined, '${offer.remoteDays} j télétravail'),
];

/// « 1 450 € brut/mois ».
String formatSalary(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return '$buffer € brut/mois';
}

/// « 2 anciens de votre école y travaillent ».
String alumniLabel(int count) => count == 1
    ? '1 ancien de votre école y travaille'
    : '$count anciens de votre école y travaillent';

/// « 6 offres compatibles avec votre profil aujourd'hui. »
String compatibleOffersLabel(int count) => switch (count) {
  0 => "Aucune nouvelle offre compatible pour l'instant.",
  1 => "1 offre compatible avec votre profil aujourd'hui.",
  _ => "$count offres compatibles avec votre profil aujourd'hui.",
};
