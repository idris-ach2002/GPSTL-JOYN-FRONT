import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../data/profile_repository.dart';
import '../../domain/student_profile.dart';
import '../controllers/profile_controller.dart';
import '../shared/profile_section_card.dart';
import '../shared/profile_view_sections.dart';

/// Page « Mon profil » de l'étudiant·e (mobile).
class MobileProfileScreen extends StatefulWidget {
  const MobileProfileScreen({super.key});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(context.read<ProfileRepository>())..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _edit() async {
    await context.push(AppRoutes.candidateProfileEdit);
    if (mounted) await _controller.load();
  }

  Future<void> _changePhoto() async {
    final message = await _controller.changePhoto();
    if (mounted && message != null) showProfileMessage(context, message);
  }

  Future<void> _replaceCv() async {
    final message = await _controller.replaceCv();
    if (mounted && message != null) showProfileMessage(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return JoynMaterialScope(
      child: MobileAppSurface(
        systemUiOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.background,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final profile = _controller.profile ?? const StudentProfile();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header(context, profile)),
                ...switch (_controller.status) {
                  ProfileLoadStatus.loading => [
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: ProfileLoadingView(),
                    ),
                  ],
                  ProfileLoadStatus.error => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ProfileErrorView(
                        message: _controller.error ?? 'Erreur de chargement.',
                        onRetry: _controller.load,
                      ),
                    ),
                  ],
                  ProfileLoadStatus.ready => [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      sliver: SliverList.separated(
                        itemCount: _sections(context, profile).length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) =>
                            _sections(context, profile)[index],
                      ),
                    ),
                  ],
                },
              ],
            );
          },
        ),
      ),
    );
  }

  /// Bandeau bleu : retour, titre, puis avatar, nom et bouton de modification.
  Widget _header(BuildContext context, StudentProfile profile) {
    final textTheme = Theme.of(context).textTheme;
    final ready = _controller.status == ProfileLoadStatus.ready;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
      decoration: const BoxDecoration(
        gradient: profileHeroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Tableau de bord',
                  onPressed: () => context.go(AppRoutes.dashboard),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: Color(0xCCFFFFFF)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mon profil',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (ready) ...[
              const SizedBox(height: 18),
              ProfileHero(
                profile: profile,
                compact: true,
                onEdit: _edit,
                onChangePhoto: _changePhoto,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, StudentProfile profile) => [
    PresentationSection(profile: profile),
    SkillsSection(profile: profile),
    EducationSection(profile: profile),
    ExperienceSection(profile: profile),
    ProjectsSection(profile: profile),
    LinksSection(profile: profile),
    CvSection(profile: profile, onReplace: _replaceCv),
    AvailabilitySection(profile: profile),
  ];
}
