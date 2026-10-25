import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../domain/student_profile.dart';
import 'profile_section_card.dart';

/// Teintes des tuiles à initiale (formations, expériences, projets).
abstract final class ProfileTints {
  static const educationBackground = Color(0xFFE8F1F6);
  static const pinkBackground = Color(0xFFFCE7F3);
  static const pinkForeground = Color(0xFFBE185D);
  static const lavenderBackground = Color(0xFFEDE9FE);
  static const lavenderForeground = Color(0xFF5B21B6);
  static const learningBackground = Color(0xFFFDE2D8);

  /// Couleurs des expériences, en alternance.
  static const experiences = [
    (pinkBackground, pinkForeground),
    (lavenderBackground, lavenderForeground),
    (AppColors.skyTint, AppColors.navy),
  ];
}

/// Dégradé bleu nuit du haut des pages profil, qui s'éclaircit jusqu'au fond.
const profileHeroGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0B2E4A),
    Color(0xFF14496F),
    Color(0xFF3F7DAA),
    Color(0xFFB9D2E4),
    AppColors.background,
  ],
  stops: [0.0, 0.35, 0.62, 0.85, 1.0],
);

/// En-tête du profil, posé sur le dégradé bleu : avatar, disponibilité, nom,
/// accroche et bouton « Modifier le profil ».
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    required this.profile,
    required this.onEdit,
    required this.onChangePhoto,
    this.compact = false,
    super.key,
  });

  final StudentProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final start = profile.availability.start.trim();
    final subtitle = [
      profile.headline.trim(),
      profile.city.trim(),
    ].where((part) => part.isNotEmpty).join(' · ');

    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: compact ? 46 : 66,
            backgroundColor: AppColors.white,
            child: ProfileAvatar(
              initials: profile.initials,
              photo: profile.photo,
              radius: compact ? 43 : 62,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: compact ? 0 : 4,
          child: IconButton.filled(
            key: const ValueKey('profile-change-photo'),
            tooltip: profile.photo == null
                ? 'Ajouter une photo'
                : 'Changer la photo',
            onPressed: onChangePhoto,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.white, width: 2),
              minimumSize: const Size.square(34),
              padding: EdgeInsets.zero,
            ),
            iconSize: 18,
            icon: const Icon(Icons.photo_camera_outlined),
          ),
        ),
      ],
    );

    final identity = Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (start.isNotEmpty) ...[
          _AvailabilityPill(start: start),
          const SizedBox(height: 10),
        ],
        Semantics(
          header: true,
          child: Text(
            profile.displayName.isEmpty ? 'Ton profil' : profile.displayName,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.white,
              fontSize: compact ? 30 : 46,
            ),
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xE6FFFFFF),
              fontSize: compact ? 15 : 18,
            ),
          ),
        ],
      ],
    );

    final editButton = FilledButton(
      key: const ValueKey('profile-edit'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      onPressed: onEdit,
      child: const Text('Modifier le profil'),
    );

    if (compact) {
      return Column(
        children: [
          avatar,
          const SizedBox(height: 14),
          identity,
          const SizedBox(height: 16),
          editButton,
        ],
      );
    }
    return Row(
      children: [
        avatar,
        const SizedBox(width: 24),
        Expanded(child: identity),
        const SizedBox(width: 16),
        editButton,
      ],
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.start});

  final String start;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Disponible dès ${start.toLowerCase()}',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.white, letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

/// Avatar : la photo de profil si elle existe, sinon les initiales.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.initials,
    this.photo,
    this.radius = 40,
    super.key,
  });

  final String initials;
  final ProfilePhoto? photo;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    if (photo != null) {
      return Semantics(
        image: true,
        label: 'Photo de profil',
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.skyMist,
          backgroundImage: MemoryImage(photo.bytes),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF5BB3E0),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.72,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class PresentationSection extends StatelessWidget {
  const PresentationSection({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio.trim();
    return ProfileSectionCard(
      title: 'Présentation',
      child: bio.isEmpty
          ? const ProfileEmptyHint(
              'Présente-toi en 3 ou 4 phrases : ce que tu sais faire, ce que tu cherches.',
            )
          : Text(
              bio,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(height: 1.65, color: AppColors.slate),
            ),
    );
  }
}

class EducationSection extends StatelessWidget {
  const EducationSection({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Formation',
      child: profile.educations.isEmpty
          ? const ProfileEmptyHint('Aucune formation pour l’instant.')
          : Column(
              children: [
                for (final education in profile.educations)
                  ProfileTimelineTile(
                    title: education.title,
                    subtitle: _join([education.school, education.period]),
                    tint: ProfileTints.educationBackground,
                    foreground: AppColors.navy,
                  ),
              ],
            ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final experiences = profile.experiences;
    return ProfileSectionCard(
      title: 'Expériences',
      child: experiences.isEmpty
          ? const ProfileEmptyHint('Aucune expérience pour l’instant.')
          : Column(
              children: [
                for (var i = 0; i < experiences.length; i++)
                  ProfileTimelineTile(
                    title: experiences[i].title,
                    subtitle: _join([
                      experiences[i].organization,
                      experiences[i].period,
                    ]),
                    description: experiences[i].description,
                    tint: ProfileTints
                        .experiences[i % ProfileTints.experiences.length]
                        .$1,
                    foreground: ProfileTints
                        .experiences[i % ProfileTints.experiences.length]
                        .$2,
                  ),
              ],
            ),
    );
  }
}

/// Une formation ou une expérience : tuile à initiale, titre, détails.
class ProfileTimelineTile extends StatelessWidget {
  const ProfileTimelineTile({
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.foreground,
    this.description = '',
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final String description;
  final Color tint;
  final Color foreground;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasDescription = description.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title.isEmpty ? '?' : title[0].toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.placeholder,
                    ),
                  ),
                ],
                if (hasDescription) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.placeholder,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({required this.profile, super.key});

  final StudentProfile profile;

  static const _cardGradients = [
    [Color(0xFFEAF3F9), Color(0xFFF8FBFD)],
    [Color(0xFFFFF1EA), Color(0xFFFFFFFF)],
  ];

  @override
  Widget build(BuildContext context) {
    final projects = profile.projects;
    return ProfileSectionCard(
      title: 'Projets',
      child: projects.isEmpty
          ? const ProfileEmptyHint('Aucun projet pour l’instant.')
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 520 ? 2 : 1;
                const spacing = 20.0;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (var i = 0; i < projects.length; i++)
                      SizedBox(
                        width: width,
                        child: _ProjectCard(
                          project: projects[i],
                          colors: _cardGradients[i % _cardGradients.length],
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.colors});

  final ProfileProject project;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: textTheme.titleMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            project.description,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.placeholder),
          ),
          if (project.tags.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in project.tags)
                  JoynInfoChip(
                    label: tag,
                    background: AppColors.skyMist,
                    foreground: AppColors.textPrimary,
                    small: true,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class SkillsSection extends StatelessWidget {
  const SkillsSection({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Compétences',
      child: profile.skills.isEmpty
          ? const ProfileEmptyHint('Aucune compétence pour l’instant.')
          : Wrap(
              spacing: 6,
              runSpacing: 8,
              children: [
                for (final skill in profile.skillsByLevel)
                  SkillLevelChip(skill: skill),
              ],
            ),
    );
  }
}

/// Compétence : bleu nuit « avancé », bleu clair intermédiaire, pêche
/// « en cours » pour un niveau débutant.
class SkillLevelChip extends StatelessWidget {
  const SkillLevelChip({required this.skill, super.key});

  final ProfileSkill skill;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (skill.level) {
      ProfileSkillLevel.advanced => (
        '${skill.name} · avancé',
        AppColors.textPrimary,
        AppColors.white,
      ),
      ProfileSkillLevel.intermediate => (
        skill.name,
        AppColors.skyMist,
        AppColors.textPrimary,
      ),
      ProfileSkillLevel.beginner => (
        '${skill.name} · en cours',
        ProfileTints.learningBackground,
        AppColors.orangeDeep,
      ),
    };
    return Semantics(
      label: '${skill.name}, niveau ${skill.level.label.toLowerCase()}',
      excludeSemantics: true,
      child: JoynInfoChip(
        label: label,
        background: background,
        foreground: foreground,
      ),
    );
  }
}

class CvSection extends StatelessWidget {
  const CvSection({required this.profile, this.onReplace, super.key});

  final StudentProfile profile;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final cv = profile.cv;
    final onReplace = this.onReplace;
    return ProfileSectionCard(
      title: 'CV',
      child: cv == null
          ? const ProfileEmptyHint('Aucun CV pour l’instant.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CvFileTile(cv: cv),
                ),
                if (onReplace != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      iconAlignment: IconAlignment.end,
                    ),
                    onPressed: onReplace,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Remplacer le CV'),
                  ),
              ],
            ),
    );
  }
}

/// Fichier du CV, avec un bouton « Remplacer » facultatif.
class CvFileTile extends StatelessWidget {
  const CvFileTile({required this.cv, this.onReplace, super.key});

  final ProfileCv cv;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onReplace = this.onReplace;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: const Icon(
        Icons.picture_as_pdf_outlined,
        color: AppColors.errorDeep,
        size: 30,
      ),
      title: Text(cv.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: cv.updatedLabel.isEmpty
          ? null
          : Text(cv.updatedLabel, style: textTheme.bodySmall),
      trailing: onReplace == null
          ? null
          : TextButton(onPressed: onReplace, child: const Text('Remplacer')),
    );
  }
}

class AvailabilitySection extends StatelessWidget {
  const AvailabilitySection({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final availability = profile.availability;
    final duration = availability.durationMonths;
    final items = [
      ('Début', availability.start.isEmpty ? '—' : availability.start),
      ('Durée', duration == null ? '—' : '$duration mois'),
      ('Rythme', availability.rhythm ?? '—'),
      ('Zone', '≤ ${availability.maxCommuteMinutes} min'),
    ];

    return ProfileSectionCard(
      title: 'Disponibilité',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 10.0;
          final width = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final (label, value) in items)
                Container(
                  width: width,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text(value, style: textTheme.titleSmall),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LinksSection extends StatelessWidget {
  const LinksSection({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final links = profile.links;
    final items = [
      (
        'GitHub',
        links.github,
        const Color(0xFF1F2328),
        const Icon(Icons.code_rounded, size: 18, color: AppColors.white),
      ),
      (
        'LinkedIn',
        links.linkedin,
        const Color(0xFF0A66C2),
        const Text(
          'in',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
      ),
      (
        'Portfolio',
        links.portfolio,
        AppColors.orange,
        const Text(
          'PF',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ].where((item) => item.$2.trim().isNotEmpty).toList();

    return ProfileSectionCard(
      title: 'Liens',
      child: items.isEmpty
          ? const ProfileEmptyHint('Ajoute ton GitHub, LinkedIn ou portfolio.')
          : Column(
              children: [
                for (final (name, url, color, badge) in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: color,
                          child: badge,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: textTheme.titleSmall),
                              Text(
                                url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Carte « Aperçu côté recruteur » : ce qu'une entreprise voit en premier.
class RecruiterPreviewCard extends StatelessWidget {
  const RecruiterPreviewCard({required this.profile, super.key});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bio = profile.bio.trim();
    final shortBio = bio.length > 140 ? '${bio.substring(0, 140)}…' : bio;
    final availability = profile.availability;
    final facts = _join([
      if (availability.start.isNotEmpty)
        'Dès ${availability.start.toLowerCase()}',
      availability.rhythm ?? '',
      profile.city,
    ]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('APERÇU CÔTÉ RECRUTEUR', style: textTheme.labelSmall),
            const SizedBox(height: 14),
            Row(
              children: [
                ProfileAvatar(
                  initials: profile.initials,
                  photo: profile.photo,
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName.isEmpty
                            ? 'Ton nom'
                            : profile.displayName,
                        style: textTheme.titleMedium,
                      ),
                      if (profile.headline.trim().isNotEmpty)
                        Text(profile.headline, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (shortBio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                shortBio,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.slateDark,
                ),
              ),
            ],
            if (profile.skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final skill in profile.skillsByLevel.take(5))
                    JoynInfoChip(
                      label: skill.name,
                      background: AppColors.skyTint,
                      foreground: AppColors.navy,
                      small: true,
                    ),
                ],
              ),
            ],
            if (facts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(facts, style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// Assemble des morceaux de texte non vides avec « · ».
String _join(List<String> parts) => parts
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .join(' · ');

/// Affiche un message court en bas de l'écran.
void showProfileMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}
