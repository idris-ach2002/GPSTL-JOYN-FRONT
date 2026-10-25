import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/material/joyn_notice.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile_completion.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_edit_controller.dart';
import '../shared/profile_completion_card.dart';
import '../shared/profile_dialogs.dart';
import '../shared/profile_edit_form.dart';
import '../shared/profile_section_card.dart';
import '../shared/profile_view_sections.dart';

/// Page « Modifier mon profil » (mobile).
class MobileProfileEditScreen extends StatefulWidget {
  const MobileProfileEditScreen({super.key});

  @override
  State<MobileProfileEditScreen> createState() =>
      _MobileProfileEditScreenState();
}

class _MobileProfileEditScreenState extends State<MobileProfileEditScreen> {
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return JoynMaterialScope(
      child: ListenableBuilder(
        listenable: _form,
        builder: (context, _) => PopScope<Object?>(
          canPop: !_form.isDirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: MobileAppSurface(
            backgroundColor: const Color(0xFFF7F8F2),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Retour au profil',
                        onPressed: _leave,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Modifier mon profil',
                          style: textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _body()),
                if (_form.status == ProfileLoadStatus.ready)
                  Material(
                    color: AppColors.surface,
                    shape: const Border(
                      top: BorderSide(color: AppColors.lineSoft),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Row(
                        children: [
                          if (_form.isDirty) ...[
                            OutlinedButton(
                              onPressed: _form.discard,
                              child: const Text('Annuler'),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: FilledButton(
                              key: const ValueKey('mobile-profile-save'),
                              onPressed: _form.isSaving ? null : _save,
                              child: _form.isSaving
                                  ? const ButtonProgress()
                                  : const Text('Enregistrer'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
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
    final saveError = _form.saveError;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saveError != null) ...[
            JoynNotice(tone: JoynNoticeTone.error, message: saveError),
            const SizedBox(height: 14),
          ],
          ProfileCompletionCard(completion: _form.completion),
          const SizedBox(height: 14),
          ProfileEditForm(
            key: ValueKey(_form.revision),
            controller: _form,
            sectionKeys: _sectionKeys,
            compact: true,
          ),
          RecruiterPreviewCard(profile: _form.draft),
        ],
      ),
    );
  }
}
