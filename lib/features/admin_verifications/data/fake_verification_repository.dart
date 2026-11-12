import '../domain/company_verification.dart';
import 'verification_repository.dart';

/// Implémentation SIMULÉE de [VerificationRepository].
///
/// Les cas « API indisponible » réussissent quand on relance la
/// vérification ; les autres problèmes demandent une décision manuelle.
class FakeVerificationRepository implements VerificationRepository {
  FakeVerificationRepository({
    this.latency = const Duration(milliseconds: 500),
    List<CompanyVerification>? seed,
  }) : _items = [...(seed ?? _seed())];

  final Duration latency;
  final List<CompanyVerification> _items;

  Future<void> _network() => Future<void>.delayed(latency);

  @override
  Future<List<CompanyVerification>> fetchVerifications({
    required VerificationFilter filter,
    String search = '',
  }) async {
    await _network();
    final query = search.trim().toLowerCase();
    final digits = query.replaceAll(RegExp(r'\s'), '');
    final result =
        _items.where((item) {
            if (!filter.matches(item.status)) return false;
            if (query.isEmpty) return true;
            return item.companyName.toLowerCase().contains(query) ||
                (digits.isNotEmpty && item.siret.contains(digits));
          }).toList()
          // Les plus anciennes d'abord : on traite la file dans l'ordre.
          ..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    return result;
  }

  @override
  Future<CompanyVerification> retryAutomatic(String id) async {
    await _network();
    final index = _indexOf(id);
    final item = _items[index];
    final now = DateTime.now();

    final CompanyVerification updated;
    if (item.issue == VerificationIssue.apiUnavailable) {
      updated = item.copyWith(
        status: VerificationStatus.verifiedAuto,
        issue: VerificationIssue.none,
        registryName: item.companyName.toUpperCase(),
        registryAddress: item.declaredAddress,
        clearApiMessage: true,
        checks: _passedChecks(item),
        history: [
          VerificationEvent(
            label: 'Vérification automatique réussie (relance)',
            date: now,
            author: 'Système',
          ),
          ...item.history,
        ],
      );
    } else {
      updated = item.copyWith(
        history: [
          VerificationEvent(
            label: 'Relance : même résultat',
            date: now,
            author: 'Système',
            note: item.issue.label,
          ),
          ...item.history,
        ],
      );
    }
    _items[index] = updated;
    return updated;
  }

  @override
  Future<CompanyVerification> decide(
    String id,
    VerificationDecision decision, {
    String note = '',
  }) async {
    await _network();
    final needsNote = decision != VerificationDecision.approve;
    if (needsNote && note.trim().isEmpty) {
      throw const VerificationException(
        'Un motif est obligatoire.',
        statusCode: 422,
      );
    }
    final index = _indexOf(id);
    final item = _items[index];
    final (status, label) = switch (decision) {
      VerificationDecision.approve => (
        VerificationStatus.verifiedManual,
        'Validée manuellement',
      ),
      VerificationDecision.requestDocument => (
        VerificationStatus.documentRequested,
        'Justificatif demandé',
      ),
      VerificationDecision.refuse => (VerificationStatus.refused, 'Refusée'),
    };
    final updated = item.copyWith(
      status: status,
      history: [
        VerificationEvent(
          label: label,
          date: DateTime.now(),
          author: 'admin@joyn.fr',
          note: note.trim(),
        ),
        ...item.history,
      ],
    );
    _items[index] = updated;
    return updated;
  }

  int _indexOf(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw const VerificationException(
        'Cette demande n’existe plus.',
        statusCode: 404,
      );
    }
    return index;
  }

  static List<VerificationCheck> _passedChecks(CompanyVerification item) => [
    VerificationCheck(
      label: 'SIRET actif dans la base SIRENE',
      outcome: CheckOutcome.passed,
      detail: item.siret,
    ),
    const VerificationCheck(
      label: 'Raison sociale identique',
      outcome: CheckOutcome.passed,
    ),
    const VerificationCheck(
      label: 'Adresse du siège cohérente',
      outcome: CheckOutcome.passed,
    ),
    const VerificationCheck(
      label: 'E-mail professionnel du recruteur',
      outcome: CheckOutcome.passed,
    ),
  ];

  static List<CompanyVerification> _seed() {
    final now = DateTime(2026, 11, 8, 9);
    CompanyVerification item({
      required int n,
      required String name,
      required String siret,
      required String city,
      required VerificationIssue issue,
      required List<VerificationCheck> checks,
      VerificationStatus status = VerificationStatus.toReview,
      String? registryName,
      String? apiMessage,
      String recruiter = 'Camille Roux',
      String? email,
      List<VerificationEvent> extraHistory = const [],
      int hoursAgo = 2,
    }) {
      final submitted = now.subtract(Duration(hours: hoursAgo + n));
      return CompanyVerification(
        id: 'ver-$n',
        companyId: 'cmp-${100 + n}',
        companyName: name,
        siret: siret,
        city: city,
        declaredAddress: '${10 + n} rue de la République, $city',
        registryName: registryName,
        registryAddress: registryName == null
            ? null
            : '${10 + n} rue de la République, $city',
        submittedAt: submitted,
        status: status,
        issue: issue,
        recruiterName: recruiter,
        recruiterEmail:
            email ??
            '${recruiter.split(' ').first.toLowerCase()}@${name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '')}.fr',
        apiMessage: apiMessage,
        checks: checks,
        history: [
          ...extraHistory,
          VerificationEvent(
            label: switch (status) {
              VerificationStatus.verifiedAuto =>
                'Vérification automatique réussie',
              _ => 'Vérification automatique : ${issue.label.toLowerCase()}',
            },
            date: submitted.add(const Duration(minutes: 1)),
            author: 'Système',
          ),
        ],
      );
    }

    const unavailable = [
      VerificationCheck(
        label: 'SIRET actif dans la base SIRENE',
        outcome: CheckOutcome.unavailable,
        detail: 'Pas de réponse de l’API',
      ),
      VerificationCheck(
        label: 'Raison sociale identique',
        outcome: CheckOutcome.unavailable,
      ),
      VerificationCheck(
        label: 'Adresse du siège cohérente',
        outcome: CheckOutcome.unavailable,
      ),
      VerificationCheck(
        label: 'E-mail professionnel du recruteur',
        outcome: CheckOutcome.passed,
      ),
    ];

    return [
      item(
        n: 1,
        name: 'Orbe Studio',
        siret: '81234567800013',
        city: 'Lyon',
        issue: VerificationIssue.apiUnavailable,
        apiMessage: 'Délai dépassé (timeout 10 s) sur api.insee.fr',
        checks: unavailable,
        hoursAgo: 30,
      ),
      item(
        n: 2,
        name: 'Atelier Brique',
        siret: '90011122200019',
        city: 'Toulouse',
        issue: VerificationIssue.siretNotFound,
        apiMessage: 'HTTP 404 : aucun établissement pour ce SIRET',
        checks: const [
          VerificationCheck(
            label: 'SIRET actif dans la base SIRENE',
            outcome: CheckOutcome.failed,
            detail: 'Aucun établissement trouvé',
          ),
          VerificationCheck(
            label: 'Raison sociale identique',
            outcome: CheckOutcome.unavailable,
          ),
          VerificationCheck(
            label: 'Adresse du siège cohérente',
            outcome: CheckOutcome.unavailable,
          ),
          VerificationCheck(
            label: 'E-mail professionnel du recruteur',
            outcome: CheckOutcome.passed,
          ),
        ],
        recruiter: 'Nathan Moreau',
        hoursAgo: 20,
      ),
      item(
        n: 3,
        name: 'Vertigo Labs',
        siret: '84455566600021',
        city: 'Montpellier',
        issue: VerificationIssue.nameMismatch,
        registryName: 'VERTIGO LABORATOIRES SAS',
        checks: const [
          VerificationCheck(
            label: 'SIRET actif dans la base SIRENE',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'Raison sociale identique',
            outcome: CheckOutcome.failed,
            detail: 'Registre : VERTIGO LABORATOIRES SAS',
          ),
          VerificationCheck(
            label: 'Adresse du siège cohérente',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'E-mail professionnel du recruteur',
            outcome: CheckOutcome.passed,
          ),
        ],
        recruiter: 'Hugo Leroy',
        hoursAgo: 12,
      ),
      item(
        n: 4,
        name: 'Maison Grenat',
        siret: '79988877700045',
        city: 'Marseille',
        issue: VerificationIssue.establishmentClosed,
        registryName: 'MAISON GRENAT',
        apiMessage: 'État administratif : F (fermé depuis le 30/06/2025)',
        checks: const [
          VerificationCheck(
            label: 'SIRET actif dans la base SIRENE',
            outcome: CheckOutcome.failed,
            detail: 'Établissement fermé le 30/06/2025',
          ),
          VerificationCheck(
            label: 'Raison sociale identique',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'Adresse du siège cohérente',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'E-mail professionnel du recruteur',
            outcome: CheckOutcome.passed,
          ),
        ],
        recruiter: 'Chloé Petit',
        hoursAgo: 6,
      ),
      item(
        n: 5,
        name: 'Pixelune',
        siret: '88877766600017',
        city: 'Bordeaux',
        issue: VerificationIssue.genericEmailDomain,
        registryName: 'PIXELUNE',
        email: 'lea.pixelune@gmail.com',
        recruiter: 'Léa Martin',
        checks: const [
          VerificationCheck(
            label: 'SIRET actif dans la base SIRENE',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'Raison sociale identique',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'Adresse du siège cohérente',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'E-mail professionnel du recruteur',
            outcome: CheckOutcome.failed,
            detail: 'Adresse gmail.com, pas le domaine de l’entreprise',
          ),
        ],
        hoursAgo: 3,
      ),
      item(
        n: 6,
        name: 'Lumen Santé',
        siret: '85566677700032',
        city: 'Lyon',
        issue: VerificationIssue.apiUnavailable,
        apiMessage: 'HTTP 503 : service SIRENE temporairement indisponible',
        checks: unavailable,
        recruiter: 'Amine Diallo',
        hoursAgo: 1,
      ),
      item(
        n: 7,
        name: 'Talent Express',
        siret: '83344455500028',
        city: 'Lille',
        status: VerificationStatus.documentRequested,
        issue: VerificationIssue.nameMismatch,
        registryName: 'TALENT EXPRESS RECRUTEMENT',
        recruiter: 'Marc Tessier',
        checks: const [
          VerificationCheck(
            label: 'SIRET actif dans la base SIRENE',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'Raison sociale identique',
            outcome: CheckOutcome.failed,
            detail: 'Registre : TALENT EXPRESS RECRUTEMENT',
          ),
        ],
        extraHistory: [
          VerificationEvent(
            label: 'Justificatif demandé',
            date: now.subtract(const Duration(hours: 40)),
            author: 'admin@joyn.fr',
            note: 'Extrait Kbis de moins de 3 mois',
          ),
        ],
        hoursAgo: 48,
      ),
      item(
        n: 8,
        name: 'Nébula Pay',
        siret: '73282932000074',
        city: 'Paris',
        status: VerificationStatus.verifiedAuto,
        issue: VerificationIssue.none,
        registryName: 'NEBULA PAY',
        checks: const [
          VerificationCheck(
            label: 'SIRET actif dans la base SIRENE',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'Raison sociale identique',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'Adresse du siège cohérente',
            outcome: CheckOutcome.passed,
          ),
          VerificationCheck(
            label: 'E-mail professionnel du recruteur',
            outcome: CheckOutcome.passed,
          ),
        ],
        hoursAgo: 72,
      ),
    ];
  }
}
