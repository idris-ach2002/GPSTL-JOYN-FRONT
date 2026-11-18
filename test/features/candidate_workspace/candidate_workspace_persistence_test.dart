import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/candidate_applications/data/pending_interests_store.dart';
import 'package:joyn_front/features/candidate_applications/domain/candidate_application.dart';

void main() {
  group('Favoris et intentions de candidature persistés', () {
    test('reconstitue les états SAVED, INTERESTED et HIDDEN du serveur', () {
      final interests = PendingInterestsStore();
      interests.restore([
        {'job_offer_id': 12, 'state': 'SAVED', 'title': 'Stage Java'},
        {
          'job_offer_id': 24,
          'state': 'INTERESTED',
          'title': 'Développeur Flutter',
          'company_name': 'JOYN',
        },
        {'job_offer_id': 36, 'state': 'HIDDEN', 'title': 'Commercial'},
      ]);
      expect(interests.items, hasLength(1));
      expect(interests.items.single.offerId, '24');
      expect(interests.items.single.jobTitle, 'Développeur Flutter');
      expect(interests.isHidden('12'), isTrue);
      expect(interests.isHidden('24'), isTrue);
      expect(interests.isHidden('36'), isTrue);
    });

    test(
      'un chargement pour un autre utilisateur efface les états précédents',
      () {
        final interests = PendingInterestsStore();
        interests.restore([
          {'job_offer_id': 1, 'state': 'INTERESTED'},
        ]);
        interests.restore([]);
        expect(interests.items, isEmpty);
        expect(interests.isHidden('1'), isFalse);
      },
    );

    test('annuler une décision rend de nouveau l’offre visible', () {
      final interests = PendingInterestsStore();
      interests.interested('42', title: 'Stage', companyName: 'Société');
      interests.undo('42');
      expect(interests.items, isEmpty);
      expect(interests.isHidden('42'), isFalse);
    });
  });

  test('conserve le détail des statuts fournis par le backend', () {
    for (final row in <String, String>{
      'PENDING': 'Envoyée · en attente',
      'VIEWED': 'Consultée par le recruteur',
      'MATCHED': 'Profil correspondant',
      'IN_REVIEW': 'En cours d’étude',
      'INTERVIEW': 'Entretien',
      'ACCEPTED': 'Candidature acceptée',
      'REJECTED': 'Candidature refusée',
      'WITHDRAWN': 'Candidature retirée',
    }.entries) {
      final application = CandidateApplication(
        id: '1',
        status: ApplicationStatus.fromApi(row.key),
        backendStatus: row.key,
      );
      expect(application.statusLabel, row.value);
    }
  });
}
