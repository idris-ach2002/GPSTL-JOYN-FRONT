import '../domain/job_offer.dart';
import '../domain/job_offer_draft.dart';
import '../domain/recruiter_company.dart';
import 'recruiter_offers_repository.dart';

class MockRecruiterOffersRepository implements RecruiterOffersRepository {
  MockRecruiterOffersRepository({
    this.latency = const Duration(milliseconds: 220),
  });
  final Duration latency;

  final List<RecruiterCompany> _companies = [
    const RecruiterCompany(
      id: 1,
      name: 'Joyn',
      siret: '73282932000074',
      activity: 'Recrutement tech',
      sector: 'SaaS B2B',
      sizeRange: '50 – 249',
      city: 'Paris, France',
      website: 'https://joyn.example',
      description: 'Joyn facilite la rencontre entre les talents et les entreprises tech.',
    ),
    const RecruiterCompany(
      id: 2,
      name: 'Orbix',
      siret: '55210055400021',
      activity: 'Solutions IA',
      sector: 'Data & Analytics',
      sizeRange: '11 – 49',
      city: 'Lyon, France',
      description: 'Orbix conçoit des solutions IA pour les équipes produit.',
    ),
    const RecruiterCompany(
      id: 3,
      name: 'Metria',
      siret: '81123456700018',
      activity: 'Data & Analytics',
      sector: 'Data & Analytics',
      sizeRange: '50 – 249',
      city: 'Paris, France',
    ),
    const RecruiterCompany(
      id: 4,
      name: 'Helios',
      siret: '41234567800019',
      activity: 'Transition écologique',
      sector: 'Transition écologique',
      sizeRange: '250 – 999',
      city: 'Lyon, France',
    ),
  ];

  late final List<JobOffer> _offers = [
    JobOffer(
      id: 1,
      companyId: 1,
      title: 'Développeur·se Full-Stack en alternance',
      contractType: ContractType.apprenticeship,
      location: 'Paris, France',
      remoteMode: RemoteMode.hybrid,
      experienceLevel: ExperienceLevel.junior,
      description: 'Rejoignez notre équipe pour développer de nouvelles fonctionnalités sur notre plateforme et contribuer à la croissance de Joyn.',
      salaryMin: 1200,
      salaryMax: 1800,
      currency: 'EUR',
      salaryPeriod: SalaryPeriod.month,
      skills: const ['React', 'TypeScript', 'Node.js', 'PostgreSQL', 'Docker'],
      rhythmType: '3 semaines entreprise / 1 semaine école',
      startDate: DateTime(2027, 9, 1),
      durationMonths: 12,
      degreeLevelRequired: 'BAC_5',
      status: JobOfferStatus.published,
      publishedAt: DateTime(2026, 10, 12),
      updatedAt: DateTime(2026, 10, 12),
      candidateCount: 14,
    ),
    JobOffer(
      id: 2,
      companyId: 2,
      title: 'Data analyst',
      contractType: ContractType.cdi,
      location: 'Lyon, France',
      remoteMode: RemoteMode.remote,
      experienceLevel: ExperienceLevel.mid,
      description: 'Analysez des données clés pour aider nos clients à prendre des décisions éclairées et contribuez à l’évolution de nos produits data.',
      salaryMin: 42000,
      salaryMax: 50000,
      skills: const [
        'SQL',
        'Python',
        'Power BI',
        'Data Visualisation',
        'Excel',
      ],
      status: JobOfferStatus.published,
      publishedAt: DateTime(2026, 10, 10),
      updatedAt: DateTime(2026, 10, 10),
      candidateCount: 8,
    ),
    JobOffer(
      id: 3,
      companyId: 3,
      title: 'Product Manager',
      contractType: ContractType.cdi,
      location: 'Paris, France',
      remoteMode: RemoteMode.hybrid,
      experienceLevel: ExperienceLevel.mid,
      description: 'Définissez la vision produit et pilotez son développement en étroite collaboration avec les équipes techniques et design.',
      salaryMin: 48000,
      salaryMax: 60000,
      skills: const [
        'Product Strategy',
        'Agile',
        'Analytics',
        'Figma',
        'Roadmap',
      ],
      status: JobOfferStatus.draft,
      updatedAt: DateTime(2026, 10, 5),
      candidateCount: 0,
    ),
    JobOffer(
      id: 4,
      companyId: 1,
      title: 'Développeur·se Mobile (React Native)',
      contractType: ContractType.cdi,
      location: 'Nantes, France',
      remoteMode: RemoteMode.hybrid,
      experienceLevel: ExperienceLevel.mid,
      description: 'Participez au développement de notre application mobile et améliorez l’expérience de nos utilisateurs.',
      salaryMin: 43000,
      salaryMax: 52000,
      skills: const [
        'React Native',
        'TypeScript',
        'Firebase',
        'CI/CD',
        'Testing',
      ],
      status: JobOfferStatus.published,
      publishedAt: DateTime(2026, 9, 28),
      updatedAt: DateTime(2026, 9, 28),
      candidateCount: 3,
    ),
    JobOffer(
      id: 5,
      companyId: 2,
      title: 'UX/UI Designer',
      contractType: ContractType.cdd,
      location: 'Télétravail',
      remoteMode: RemoteMode.remote,
      experienceLevel: ExperienceLevel.mid,
      description: 'Concevez des expériences utilisateur intuitives et impactantes pour nos produits web et mobile.',
      skills: const [
        'Figma',
        'Design System',
        'UX Research',
        'Prototypage',
        'UI Design',
      ],
      status: JobOfferStatus.closed,
      publishedAt: DateTime(2026, 9, 3),
      updatedAt: DateTime(2026, 10, 3),
      candidateCount: 0,
    ),
  ];

  Future<void> _wait() async {
    if (latency == Duration.zero) {
      return;
    }
    await Future<void>.delayed(latency);
  }

  @override
  Future<List<RecruiterCompany>> fetchCompanies() async {
    await _wait();
    return List.unmodifiable(_companies);
  }

  @override
  Future<RecruiterCompany?> findCompanyBySiret(String siret) async {
    await _wait();
    final normalized = siret.replaceAll(RegExp(r'\D'), '');
    for (final company in _companies) {
      if (company.siret == normalized) return company;
    }
    return null;
  }

  @override
  Future<RecruiterCompany> createCompany(RecruiterCompanyDraft draft) async {
    await _wait();
    final company = RecruiterCompany(
      id: _companies.length + 1,
      name: draft.name.trim(),
      siret: draft.siret.replaceAll(RegExp(r'\D'), ''),
      activity: draft.sector,
      sector: draft.sector,
      sizeRange: draft.sizeRange,
      city: draft.city.trim(),
      website: draft.website.trim().isEmpty ? null : draft.website.trim(),
      description: draft.description.trim(),
    );
    _companies.add(company);
    return company;
  }

  @override
  Future<List<JobOffer>> fetchOffers() async {
    await _wait();
    return List.unmodifiable(_offers);
  }

  @override
  Future<JobOffer?> fetchOffer(int id) async {
    await _wait();
    for (final offer in _offers) {
      if (offer.id == id) return offer;
    }
    return null;
  }

  @override
  Future<JobOffer> createOffer(
    JobOfferDraft draft,
    JobOfferStatus status,
  ) async {
    await _wait();
    final now = DateTime.now();
    final offer = JobOffer(
      id: (_offers.map((e) => e.id).fold<int>(0, (a, b) => a > b ? a : b)) + 1,
      companyId: draft.companyId,
      title: draft.title,
      contractType: draft.contractType,
      location: draft.location,
      remoteMode: draft.remoteMode,
      experienceLevel: draft.experienceLevel,
      description: draft.description,
      salaryMin: draft.salaryMin,
      salaryMax: draft.salaryMax,
      currency: draft.currency,
      salaryPeriod: draft.salaryPeriod,
      skills: List.unmodifiable(draft.skills),
      rhythmType: draft.rhythmType,
      startDate: draft.startDate,
      durationMonths: draft.durationMonths,
      degreeLevelRequired: draft.degreeLevelRequired,
      status: status,
      publishedAt: status == JobOfferStatus.published ? now : null,
      updatedAt: now,
    );
    _offers.insert(0, offer);
    return offer;
  }

  @override
  Future<JobOffer> updateOffer(int id, JobOfferDraft draft) async {
    await _wait();
    final index = _offers.indexWhere((offer) => offer.id == id);
    if (index < 0) throw StateError('Offre introuvable');
    final previous = _offers[index];
    final updated = JobOffer(
      id: previous.id,
      companyId: draft.companyId,
      title: draft.title,
      contractType: draft.contractType,
      location: draft.location,
      remoteMode: draft.remoteMode,
      experienceLevel: draft.experienceLevel,
      description: draft.description,
      salaryMin: draft.salaryMin,
      salaryMax: draft.salaryMax,
      currency: draft.currency,
      salaryPeriod: draft.salaryPeriod,
      skills: List.unmodifiable(draft.skills),
      rhythmType: draft.rhythmType,
      startDate: draft.startDate,
      durationMonths: draft.durationMonths,
      degreeLevelRequired: draft.degreeLevelRequired,
      status: previous.status,
      publishedAt: previous.publishedAt,
      updatedAt: DateTime.now(),
      candidateCount: previous.candidateCount,
    );
    _offers[index] = updated;
    return updated;
  }

  @override
  Future<void> closeOffer(int id, {String? reason}) async {
    await _wait();
    final index = _offers.indexWhere((offer) => offer.id == id);
    if (index < 0) throw StateError('Offre introuvable');
    _offers[index] = _offers[index].copyWith(
      status: JobOfferStatus.closed,
      updatedAt: DateTime.now(),
    );
  }
}
