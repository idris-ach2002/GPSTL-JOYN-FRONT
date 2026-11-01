import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/recruiter_candidates/data/mock_recruiter_candidate_repository.dart';
import 'package:joyn_front/features/recruiter_candidates/presentation/recruiter_candidate_controller.dart';

void main() {
  test('le carrousel peut sélectionner un candidat sans recharger', () async {
    final controller = RecruiterCandidateController(
      MockRecruiterCandidateRepository(latency: Duration.zero),
    );

    await controller.load();

    expect(controller.data, isNotNull);
    expect(controller.data!.items.length, greaterThan(1));
    expect(controller.currentIndex, 0);

    final secondId = controller.data!.items[1].id;
    controller.selectIndex(1);

    expect(controller.currentIndex, 1);
    expect(controller.currentCandidate?.id, secondId);
  });
}
