import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/material/joyn_chip_group.dart';
import 'package:joyn_front/design_system/material/joyn_notice.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/features/profile/data/profile_repository.dart';
import 'package:joyn_front/features/profile/domain/profile_completion.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_controller.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_edit_controller.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_completion_card.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_dialogs.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_edit_form.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_section_card.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_view_sections.dart';
import 'package:joyn_front/features/profile/presentation/web/widgets/profile_top_bar.dart';

/// Page « Modifier mon profil » (web).
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final ProfileEditController _form;
  final _sectionKeys = {
    for (final section in ProfileSection.values) section: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _form = ProfileEditController(context.read<ProfileRepository>())..load();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.candidateProfile);
    }
  }

  Future<void> _leave() async {
    if (_form.isDirty) {
      final leave = await confirmDiscardChanges(context);
      if (!leave || !mounted) return;
      _form.discard();
    }
    _close();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final saved = await _form.save();
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Profil enregistré. Tes scores sont recalculés.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    _close();
  }

  void _scrollTo(ProfileSection section) {
    final sectionContext = _sectionKeys[section]?.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return JoynMaterialScope(
      child: ListenableBuilder(
        listenable: _form,
        builder: (context, _) => PopScope<Object?>(
          canPop: !_form.isDirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ProfileTopBar(
                    leading: TextButton.icon(
                      onPressed: _leave,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Retour au profil'),
                    ),
                    actions: [
                      if (_form.isDirty &&
                          MediaQuery.sizeOf(context).width >= 760)
                        const JoynInfoChip(
                          label: 'Modifications non enregistrées',
                          icon: Icons.edit_note_rounded,
                          background: AppColors.warningTint,
                          foreground: AppColors.warningDeep,
                          small: true,
                        ),
                      OutlinedButton(
                        style: JoynButtonStyles.rounded,
                        onPressed: _form.isDirty ? _form.discard : null,
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        key: const ValueKey('profile-save'),
                        style: JoynButtonStyles.rounded,
                        onPressed: _form.isSaving ? null : _save,
                        child: _form.isSaving
                            ? const ButtonProgress()
                            : const Text('Enregistrer'),
                      ),
                    ],
                  ),
                  Expanded(child: _body(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (_form.status) {
      case ProfileLoadStatus.loading:
        return const ProfileLoadingView();
      case ProfileLoadStatus.error:
        return ProfileErrorView(
          message: _form.loadError ?? 'Erreur de chargement.',
          onRetry: _form.load,
        );
      case ProfileLoadStatus.ready:
        break;
    }

    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 640;
    final showNav = width >= 1240;
    final showSide = width >= 940;
    final textTheme = Theme.of(context).textTheme;
    final saveError = _form.saveError;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text('Modifier mon profil', style: textTheme.headlineMedium),
        ),
        const SizedBox(height: 4),
        Text(
          'Plus ton profil est complet, plus ton score de compatibilité est précis.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.slate),
        ),
        const SizedBox(height: 20),
        if (saveError != null) ...[
          JoynNotice(tone: JoynNoticeTone.error, message: saveError),
          const SizedBox(height: 16),
        ],
        if (!showSide) ...[
          ProfileCompletionCard(completion: _form.completion),
          const SizedBox(height: 16),
        ],
        ProfileEditForm(
          key: ValueKey(_form.revision),
          controller: _form,
          sectionKeys: _sectionKeys,
          compact: compact,
        ),
        if (!showSide) RecruiterPreviewCard(profile: _form.draft),
      ],
    );

    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileCompletionCard(completion: _form.completion),
        const SizedBox(height: 16),
        RecruiterPreviewCard(profile: _form.draft),
      ],
    );

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: compact
                ? const EdgeInsets.fromLTRB(16, 20, 16, 32)
                : const EdgeInsets.fromLTRB(24, 28, 24, 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showNav) ...[
                  SizedBox(
                    width: 210,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ProfileSectionNav(
                          completion: _form.completion,
                          onSelected: _scrollTo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
                Expanded(child: form),
                if (showSide) ...[
                  const SizedBox(width: 20),
                  SizedBox(width: 320, child: side),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
