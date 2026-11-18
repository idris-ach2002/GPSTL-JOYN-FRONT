import 'account_security_dialog.dart';
import '../../../../core/network/api_client.dart';
import 'password_dialog.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../notifications/presentation/notifications_controller.dart';
import '../../domain/candidate_settings.dart';
import '../candidate_settings_controller.dart';

/// Carte blanche d'une section de paramètres.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.skyTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.navy, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppFonts.display,
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          color: AppColors.slate,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Section « Visibilité du profil » : quatre interrupteurs, enregistrés
/// immédiatement.
class VisibilitySection extends StatelessWidget {
  const VisibilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CandidateSettingsController>();
    final v = c.saved.visibility;
    void set(VisibilitySettings next) => c.setVisibility(next);

    Widget toggle(
      String title,
      String body,
      bool value,
      VisibilitySettings on,
      VisibilitySettings off,
    ) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: c.savingVisibility ? null : (x) => set(x ? on : off),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(body, style: const TextStyle(fontSize: 13)),
      );
    }

    return SettingsCard(
      icon: Icons.visibility_outlined,
      title: 'Visibilité du profil',
      subtitle: 'Choisis ce que les recruteurs et les autres membres voient.',
      child: Column(
        children: [
          toggle(
            'Visible des recruteurs',
            'Ton profil peut apparaître dans leurs recommandations. Désactivé, '
                'tu restes invisible, même pour les offres où tu as postulé.',
            v.visibleToRecruiters,
            v.copyWith(visibleToRecruiters: true),
            v.copyWith(visibleToRecruiters: false),
          ),
          toggle(
            'Visible des autres membres',
            'Les autres utilisateurs de JOYN peuvent consulter ton profil.',
            v.visibleToOthers,
            v.copyWith(visibleToOthers: true),
            v.copyWith(visibleToOthers: false),
          ),
          toggle(
            'Afficher mon nom de famille',
            'Sinon, seule son initiale apparaît (ex. « Alex D. »).',
            v.showLastName,
            v.copyWith(showLastName: true),
            v.copyWith(showLastName: false),
          ),
          toggle(
            'Afficher mes liens',
            'GitHub, LinkedIn et portfolio sur ton profil public.',
            v.showContactLinks,
            v.copyWith(showContactLinks: true),
            v.copyWith(showContactLinks: false),
          ),
        ],
      ),
    );
  }
}

/// Section « Ce que je recherche » : contrats, télétravail, rémunération.
class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final _salary = TextEditingController();
  SearchPreferences? _shown;

  @override
  void dispose() {
    _salary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CandidateSettingsController>();
    final draft = c.draft;
    // Resynchronise le champ quand le brouillon change de l'extérieur
    // (chargement, annulation, enregistrement).
    if (_shown != draft && '${draft.minSalary ?? ''}' != _salary.text) {
      _salary.text = draft.minSalary?.toString() ?? '';
    }
    _shown = draft;

    const label = TextStyle(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: AppColors.textPrimary,
    );

    return SettingsCard(
      icon: Icons.tune_rounded,
      title: 'Ce que je recherche',
      subtitle: 'Ces critères filtrent les offres proposées dans « Matchs ».',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Types de contrat', style: label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in ContractType.values)
                _Pill(
                  label: type.label,
                  selected: draft.contractTypes.contains(type),
                  onTap: () => c.toggleContract(type),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Télétravail', style: label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                label: 'Indifférent',
                selected: draft.remotePolicy == null,
                onTap: () =>
                    c.editPreferences(draft.copyWith(clearRemote: true)),
              ),
              for (final policy in RemotePolicy.values)
                _Pill(
                  label: policy.label,
                  selected: draft.remotePolicy == policy,
                  onTap: () =>
                      c.editPreferences(draft.copyWith(remotePolicy: policy)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Rémunération minimum', style: label),
          const SizedBox(height: 8),
          SizedBox(
            width: 260,
            child: TextField(
              controller: _salary,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                hintText: 'Aucun minimum',
                suffixText: '€ brut / mois',
              ),
              onChanged: (value) {
                final amount = int.tryParse(value);
                c.editPreferences(
                  amount == null
                      ? draft.copyWith(clearSalary: true)
                      : draft.copyWith(minSalary: amount),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: c.preferencesDirty && !c.savingPreferences
                    ? c.savePreferences
                    : null,
                child: Text(
                  c.savingPreferences ? 'Enregistrement…' : 'Enregistrer',
                ),
              ),
              if (c.preferencesDirty)
                TextButton(
                  onPressed: c.discardPreferences,
                  child: const Text('Annuler les modifications'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section « Notifications » : compteur et actions groupées.
class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NotificationsController>();
    final api = context.read<ApiClient?>();
    final read = n.items.where((x) => x.isRead).length;
    return SettingsCard(
      icon: Icons.notifications_none_rounded,
      title: 'Notifications',
      subtitle: n.unreadCount == 0
          ? 'Tu es à jour.'
          : '${n.unreadCount} notification${n.unreadCount > 1 ? 's' : ''} '
                'non lue${n.unreadCount > 1 ? 's' : ''}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (api != null) AccountAlertPreferences(api: api),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onOpen,
                icon: const Icon(Icons.list_rounded, size: 18),
                label: const Text('Voir les notifications'),
              ),
              OutlinedButton(
                onPressed: n.unreadCount == 0 ? null : n.markAllRead,
                child: const Text('Tout marquer comme lu'),
              ),
              OutlinedButton(
                onPressed: read == 0
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        String text;
                        try {
                          final count = await n.deleteRead();
                          text = count <= 1
                              ? '$count notification lue supprimée.'
                              : '$count notifications lues supprimées.';
                        } catch (_) {
                          text = 'La suppression a échoué.';
                        }
                        messenger.showSnackBar(SnackBar(content: Text(text)));
                      },
                child: Text(
                  read == 0
                      ? 'Supprimer les lues'
                      : 'Supprimer les lues ($read)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section « Compte » : adresse de connexion et déconnexion.
class AccountSection extends StatelessWidget {
  const AccountSection({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final email = context.watch<CandidateSettingsController>().saved.email;
    final api = context.read<ApiClient?>();
    return SettingsCard(
      icon: Icons.person_outline_rounded,
      title: 'Compte',
      subtitle: email.isEmpty ? 'Compte candidat' : 'Connecté avec $email',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.candidateProfileEdit),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Modifier mon profil et mon CV'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.candidateMessages),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: const Text('Ouvrir la messagerie'),
          ),
          if (api != null)
            OutlinedButton.icon(
              onPressed: () async {
                final changed = await showPasswordDialog(context, api);
                if (changed == true && context.mounted) onSignOut();
              },
              icon: const Icon(Icons.key_outlined, size: 18),
              label: const Text('Modifier mon mot de passe'),
            ),
          if (api != null)
            for (final (email, title, icon) in [
              (true, 'Changer mon adresse e-mail', Icons.alternate_email),
              (
                false,
                'Déconnecter mes appareils',
                Icons.phonelink_erase_outlined,
              ),
            ])
              OutlinedButton.icon(
                onPressed: () async {
                  final updated = await showAccountSecurityDialog(
                    context,
                    api,
                    updateEmail: email,
                  );
                  if (updated == true && context.mounted) onSignOut();
                },
                icon: Icon(icon, size: 18),
                label: Text(title),
              ),
          OutlinedButton.icon(
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.errorDeep,
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

/// Puce de choix : bleu nuit et texte blanc quand elle est sélectionnée.
///
/// Couleurs fixées ici : les puces Material du thème global mettaient un
/// texte foncé sur le fond bleu nuit de l'état sélectionné.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.navy : AppColors.white,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? AppColors.navy : AppColors.line),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
