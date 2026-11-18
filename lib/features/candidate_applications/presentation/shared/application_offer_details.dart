import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../candidate_discover/data/api_recommended_offers_repository.dart';
import '../../../candidate_discover/presentation/shared/discover_states.dart';
import '../../domain/candidate_application.dart';
import 'open_conversation.dart';

Future<void> openApplicationOffer(
  BuildContext context,
  CandidateApplication application,
) {
  final api = context.read<ApiClient?>();
  final id = int.tryParse(application.offerId ?? '');
  final offer = api == null || id == null
      ? null
      : api.getJson('/api/v1/candidates/offers/$id');
  return showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Détail de l’offre'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: offer == null
              ? _summary(
                  application,
                  'La fiche complète de cette offre est indisponible.',
                )
              : FutureBuilder(
                  future: offer,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.data case {
                      'offer': final Map details,
                      'company': final Map company,
                    }) {
                      return OfferDetailsView(
                        offer: ApiRecommendedOffersRepository.mapOffer({
                          ...Map<String, dynamic>.from(details),
                          'company': Map<String, dynamic>.from(company),
                        }),
                        showMatching: false,
                      );
                    }
                    return _summary(
                      application,
                      'La fiche complète n’a pas pu être chargée.',
                    );
                  },
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: const Text('Fermer'),
        ),
        if (application.status != ApplicationStatus.interested)
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(dialog);
              openApplicationConversation(context, application);
            },
            child: Text(
              application.hasConversation || application.canStartConversation
                  ? 'Ouvrir la conversation'
                  : 'Suivi de la candidature',
            ),
          ),
      ],
    ),
  );
}

Widget _summary(CandidateApplication application, String reason) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(application.jobTitle ?? 'Offre'),
    if (application.companyName != null) Text(application.companyName!),
    const SizedBox(height: 12),
    Text(reason),
  ],
);
