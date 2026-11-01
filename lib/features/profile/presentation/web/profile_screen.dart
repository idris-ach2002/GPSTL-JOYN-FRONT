import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:joyn_front/app/routing/app_routes.dart';
import 'package:joyn_front/design_system/theme/joyn_material_theme.dart';
import 'package:joyn_front/features/profile/data/profile_repository.dart';
import 'package:joyn_front/features/profile/domain/student_profile.dart';
import 'package:joyn_front/features/profile/presentation/controllers/profile_controller.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_section_card.dart';
import 'package:joyn_front/features/profile/presentation/shared/profile_view_sections.dart';
import 'package:joyn_front/features/profile/presentation/web/widgets/profile_nav_bar.dart';

/// Page « Mon profil » de l'étudiant·e (web).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      child: Scaffold(
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final profile = _controller.profile ?? const StudentProfile();
            return SingleChildScrollView(
              child: Stack(
                children: [
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 560,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: profileHeroGradient),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 18, 28, 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ProfileNavBar(
                                firstName: profile.firstName,
                                initials: profile.initials,
                                photo: profile.photo,
                              ),
                              const SizedBox(height: 28),
                              switch (_controller.status) {
                                ProfileLoadStatus.loading => const SizedBox(
                                  height: 320,
                                  child: ProfileLoadingView(),
                                ),
                                ProfileLoadStatus.error => Card(
                                  child: ProfileErrorView(
                                    message:
                                        _controller.error ??
                                        'Erreur de chargement.',
                                    onRetry: _controller.load,
                                  ),
                                ),
                                ProfileLoadStatus.ready => _ProfileBody(
                                  profile: profile,
                                  onEdit: _edit,
                                  onChangePhoto: _changePhoto,
                                  onReplaceCv: _replaceCv,
                                ),
                              },
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.onEdit,
    required this.onChangePhoto,
    required this.onReplaceCv,
  });

  final StudentProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;
  final VoidCallback onReplaceCv;

  /// Largeur à partir de laquelle le contenu passe sur deux colonnes.
  static const double _twoColumnsBreakpoint = 980;

  @override
  Widget build(BuildContext context) {
    final twoColumns =
        MediaQuery.sizeOf(context).width >= _twoColumnsBreakpoint;

    final presentation = PresentationSection(profile: profile);
    final education = EducationSection(profile: profile);
    final experiences = ExperienceSection(profile: profile);
    final projects = ProjectsSection(profile: profile);
    final links = LinksSection(profile: profile);
    final skills = SkillsSection(profile: profile);
    final cv = CvSection(profile: profile, onReplace: onReplaceCv);
    final availability = AvailabilitySection(profile: profile);

    Widget column(List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children)
          Padding(padding: const EdgeInsets.only(bottom: 24), child: child),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileHero(
          profile: profile,
          compact: !twoColumns,
          onEdit: onEdit,
          onChangePhoto: onChangePhoto,
        ),
        const SizedBox(height: 40),
        if (twoColumns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: column([presentation, education, experiences, projects]),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: column([links, skills, cv, availability]),
              ),
            ],
          )
        else
          column([
            presentation,
            skills,
            education,
            experiences,
            projects,
            links,
            cv,
            availability,
          ]),
      ],
    );
  }
}
