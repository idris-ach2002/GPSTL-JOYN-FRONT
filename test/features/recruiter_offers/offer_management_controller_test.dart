import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_offers/data/mock_recruiter_offers_repository.dart';
import 'package:joyn_front/features/recruiter_offers/domain/job_offer.dart';
import 'package:joyn_front/features/recruiter_offers/presentation/controllers/offer_management_controller.dart';

void main() {
  group('OfferManagementController', () {
    late OfferManagementController controller;

    setUp(() async {
      controller = OfferManagementController(
        MockRecruiterOffersRepository(latency: Duration.zero),
      );
      await controller.load();
    });

    test('calcule les compteurs par statut', () {
      expect(controller.totalCount, 5);
      expect(controller.count(JobOfferStatus.published), 3);
      expect(controller.count(JobOfferStatus.draft), 1);
      expect(controller.count(JobOfferStatus.closed), 1);
    });

    test('filtre par entreprise, statut et recherche', () {
      controller.setCompanyFilter(1);
      expect(
        controller.visibleOffers.every((offer) => offer.companyId == 1),
        isTrue,
      );

      controller
        ..setCompanyFilter(null)
        ..setStatusFilter(JobOfferStatus.draft);
      expect(controller.visibleOffers, hasLength(1));
      expect(controller.visibleOffers.single.title, 'Product Manager');

      controller
        ..setStatusFilter(null)
        ..setQuery('postgresql');
      expect(controller.visibleOffers.map((offer) => offer.id), contains(1));
    });

    test('la clôture déplace l’offre vers le statut CLOSED', () async {
      final published = controller.offers.firstWhere(
        (offer) => offer.status == JobOfferStatus.published,
      );

      expect(
        await controller.closeOffer(published.id, reason: 'Poste pourvu'),
        isTrue,
      );
      expect(
        controller.offers
            .firstWhere((offer) => offer.id == published.id)
            .status,
        JobOfferStatus.closed,
      );
    });
  });
}
