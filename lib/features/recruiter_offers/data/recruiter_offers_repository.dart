import '../domain/job_offer.dart';
import '../domain/job_offer_draft.dart';
import '../domain/recruiter_company.dart';

abstract interface class RecruiterOffersRepository {
  Future<List<RecruiterCompany>> fetchCompanies();
  Future<RecruiterCompany?> findCompanyBySiret(String siret);
  Future<RecruiterCompany> createCompany(RecruiterCompanyDraft draft);
  Future<List<JobOffer>> fetchOffers();
  Future<JobOffer?> fetchOffer(int id);
  Future<JobOffer> createOffer(JobOfferDraft draft, JobOfferStatus status);
  Future<JobOffer> updateOffer(int id, JobOfferDraft draft);
  Future<void> closeOffer(int id, {String? reason});
  Future<void> deleteOffer(int id);
}
