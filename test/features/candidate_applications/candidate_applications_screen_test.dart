import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/theme/app_theme.dart';
import 'package:joyn_front/features/auth/data/fake_auth_repository.dart';
import 'package:joyn_front/features/auth/presentation/auth_controller.dart';
import 'package:joyn_front/features/candidate_applications/data/mock_candidate_applications_repository.dart';
import 'package:joyn_front/features/candidate_applications/domain/candidate_application.dart';
import 'package:joyn_front/features/candidate_applications/presentation/candidate_applications_controller.dart';
import 'package:joyn_front/features/candidate_applications/presentation/mobile/mobile_candidate_applications_screen.dart';
import 'package:joyn_front/features/candidate_applications/presentation/web/candidate_applications_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<CandidateApplication> applications = const [],
  Size size = const Size(1440, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final controller = CandidateApplicationsController(
    MockCandidateApplicationsRepository(
      latency: Duration.zero,
      applications: applications,
    ),
    clock: () => DateTime(2026, 10, 14),
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthController(FakeAuthRepository(latency: Duration.zero)),
        ),
        ChangeNotifierProvider.value(value: controller),
      ],
      child: MaterialApp(theme: AppTheme.light, home: screen),
    ),
  );
  // Pas d'`await` : dans un testWidgets le temps est simulé, c'est
  // pumpAndSettle qui fait avancer le délai du repository.
  controller.load();
  await tester.pumpAndSettle();
}

final sample = [
  CandidateApplication(
    id: 'i1',
    status: ApplicationStatus.interested,
    companyName: 'Entreprise XY',
    jobTitle: 'Dév Front-End Vue',
    matchScore: 84,
    appliedAt: DateTime(2026, 10, 14),
  ),
  CandidateApplication(
    id: 'e1',
    status: ApplicationStatus.interview,
    companyName: 'Studio Nova',
    matchScore: 91,
    appliedAt: DateTime(2026, 10, 10),
    interviewAt: DateTime(2026, 10, 15),
  ),
  CandidateApplication(
    id: 's1',
    status: ApplicationStatus.sent,
    appliedAt: DateTime(2026, 10, 12),
  ),
];

void main() {
  testWidgets('web : colonnes vides tant que le backend n’est pas branché', (
    tester,
  ) async {
    await pumpScreen(tester, const WebCandidateApplicationsScreen());

    expect(find.text('Mes candidatures'), findsOneWidget);
    expect(
      find.text('0 candidature · 0 entretien cette semaine'),
      findsOneWidget,
    );
    for (final status in ApplicationStatus.values) {
      expect(find.text(status.label), findsOneWidget);
    }
    expect(find.text('Aucune candidature pour le moment.'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('web : affiche chaque candidature avec le pied de son statut', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const WebCandidateApplicationsScreen(),
      applications: sample,
    );

    expect(
      find.text('3 candidatures · 1 entretien cette semaine'),
      findsOneWidget,
    );
    expect(find.text('Entreprise XY'), findsOneWidget);
    expect(find.text('Aujourd’hui'), findsOneWidget);
    expect(find.text('84 %'), findsOneWidget);
    expect(find.text('Envoyer ma candidature'), findsOneWidget);
    expect(find.text('Entretien · 15/10/2026'), findsOneWidget);
    expect(find.text('En attente de l’entreprise'), findsOneWidget);
    // Candidature sans données : tirets à la place des valeurs.
    expect(find.text('—'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web : une candidature envoyée explique l’attente au clic', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const WebCandidateApplicationsScreen(),
      applications: sample,
    );

    await tester.tap(find.byKey(const ValueKey('application-s1')));
    await tester.pump();

    expect(
      find.text('La conversation s’ouvrira quand l’entreprise aura répondu.'),
      findsOneWidget,
    );
  });

  testWidgets('web : colonnes empilées sur petit écran, sans débordement', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const WebCandidateApplicationsScreen(),
      applications: sample,
      size: const Size(700, 1000),
    );

    expect(find.text('Entretiens'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile : filtre la liste par statut', (tester) async {
    await pumpScreen(
      tester,
      const MobileCandidateApplicationsScreen(),
      applications: sample,
      size: const Size(390, 844),
    );

    expect(find.byType(ChoiceChip), findsNWidgets(5));
    expect(find.text('Studio Nova'), findsOneWidget);
    expect(find.text('Entreprise XY'), findsOneWidget);

    final interviews = find.text('Entretiens (1)');
    await tester.ensureVisible(interviews);
    await tester.pumpAndSettle();
    await tester.tap(interviews);
    await tester.pumpAndSettle();

    expect(find.text('Studio Nova'), findsOneWidget);
    expect(find.text('Entreprise XY'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
