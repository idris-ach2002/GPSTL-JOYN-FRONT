import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../domain/candidate_application.dart';
import '../candidate_applications_controller.dart';

/// Clic sur une candidature : ouvre (ou crée) la conversation avec le
/// recruteur, ou explique pourquoi ce n'est pas encore possible.
Future<void> openApplicationConversation(
  BuildContext context,
  CandidateApplication application,
) async {
  // La page « Messages » retrouve le fil à partir de la candidature : elle
  // ouvre la conversation existante, ou propose de la démarrer (entretien).
  if (application.hasConversation || application.canStartConversation) {
    context.go(AppRoutes.candidateConversation(application.id));
    return;
  }

  final controller = context.read<CandidateApplicationsController>();
  final outcome = await controller.openConversation(application);
  if (!context.mounted) return;

  switch (outcome) {
    case ConversationReady():
      context.go(AppRoutes.candidateConversation(application.id));
    case ConversationUnavailable():
      _showMessage(context, switch (application.status) {
        ApplicationStatus.rejected => 'Cette candidature est close.',
        ApplicationStatus.interested =>
          'Envoie ta candidature pour pouvoir échanger avec le recruteur.',
        _ => 'La conversation s’ouvrira quand l’entreprise aura répondu.',
      });
    case ConversationFailed(:final message):
      _showMessage(context, message);
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
