import 'package:flutter/material.dart';

import '../../../../design_system/material/joyn_chip_group.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/profile_completion.dart';
import '../../domain/profile_options.dart';
import '../../domain/student_profile.dart';
import '../controllers/profile_edit_controller.dart';
import 'profile_dialogs.dart';
import 'profile_section_card.dart';
import 'profile_view_sections.dart';

/// Toutes les sections de « Modifier mon profil », communes au web et au
/// mobile.
///
/// Donner `ValueKey(controller.revision)` comme clé : les champs texte sont
/// alors réinitialisés après un chargement ou une annulation.
class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({
    required this.controller,
    required this.sectionKeys,
    this.compact = false,
    super.key,
  });

  final ProfileEditController controller;

  /// Une clé par section, pour pouvoir y faire défiler la page.
  final Map<ProfileSection, GlobalKey> sectionKeys;

  /// Champs empilés (petits écrans).
  final bool compact;

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late final StudentProfile _initial = widget.controller.draft;

  late final _firstName = TextEditingController(text: _initial.firstName);
  late final _lastName = TextEditingController(text: _initial.lastName);
  late final _headline = TextEditingController(text: _initial.headline);
  late final _city = TextEditingController(text: _initial.city);
  late final _email = TextEditingController(text: _initial.email);
  late final _bio = TextEditingController(text: _initial.bio);
  late final _github = TextEditingController(text: _initial.links.github);
  late final _linkedin = TextEditingController(text: _initial.links.linkedin);
  late final _portfolio = TextEditingController(text: _initial.links.portfolio);
  final _newSkill = TextEditingController();
  final _newRole = TextEditingController();
  final _newOrganization = TextEditingController();
  final _newPeriod = TextEditingController();
  final _newDescription = TextEditingController();
  bool _experienceFormOpen = false;
  bool _experienceAttempted = false;

  ProfileEditController get _form => widget.controller;

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _headline,
      _city,
      _email,
      _bio,
      _github,
      _linkedin,
      _portfolio,
      _newSkill,
      _newRole,
      _newOrganization,
      _newPeriod,
      _newDescription,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSkill([String? name]) {
    final added = _form.addSkill(name ?? _newSkill.text);
    if (added && name == null) _newSkill.clear();
  }

  void _addExperience() {
    final added = _form.addExperience(
      title: _newRole.text,
      organization: _newOrganization.text,
      period: _newPeriod.text,
      description: _newDescription.text,
    );
    if (!added) {
      setState(() => _experienceAttempted = true);
      return;
    }
    for (final controller in [
      _newRole,
      _newOrganization,
      _newPeriod,
      _newDescription,
    ]) {
      controller.clear();
    }
    setState(() {
      _experienceFormOpen = false;
      _experienceAttempted = false;
    });
  }

  Future<void> _pickPhoto() async {
    final error = await _form.pickPhoto();
    if (mounted && error != null) showProfileMessage(context, error);
  }

  Future<void> _pickCv() async {
    final error = await _form.pickCv();
    if (mounted && error != null) showProfileMessage(context, error);
  }

  Future<void> _addEducation() async {
    final education = await showAddEducationDialog(context);
    if (education != null) _form.addEducation(education);
  }

  Widget _pair(Widget first, Widget second) {
    if (widget.compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, const SizedBox(height: 16), second],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 14),
        Expanded(child: second),
      ],
    );
  }

  Widget _section(ProfileSection section, Widget card) {
    return Padding(
      key: widget.sectionKeys[section],
      padding: const EdgeInsets.only(bottom: 16),
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = _form.draft;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ------------------------------------------------------------------
        _section(
          ProfileSection.identity,
          ProfileSectionCard(
            title: 'Photo et identité',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      initials: draft.initials,
                      photo: draft.photo,
                      radius: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 4,
                            children: [
                              TextButton.icon(
                                key: const ValueKey('profile-pick-photo'),
                                onPressed: _pickPhoto,
                                icon: const Icon(
                                  Icons.photo_camera_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  draft.photo == null
                                      ? 'Ajouter une photo'
                                      : 'Changer la photo',
                                ),
                              ),
                              if (draft.photo != null)
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.slate,
                                  ),
                                  onPressed: _form.removePhoto,
                                  child: const Text('Supprimer'),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'JPG ou PNG, 5 Mo max. Une photo augmente les réponses des recruteurs.',
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _pair(
                  TextField(
                    key: const ValueKey('profile-first-name'),
                    controller: _firstName,
                    onChanged: _form.setFirstName,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      errorText: _form.visibleErrorFor(
                        ProfileEditField.firstName,
                      ),
                    ),
                  ),
                  TextField(
                    key: const ValueKey('profile-last-name'),
                    controller: _lastName,
                    onChanged: _form.setLastName,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      errorText: _form.visibleErrorFor(
                        ProfileEditField.lastName,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('profile-headline'),
                  controller: _headline,
                  onChanged: _form.setHeadline,
                  maxLength: StudentProfile.headlineMaxLength,
                  decoration: const InputDecoration(
                    labelText: 'Titre du profil',
                    hintText:
                        'Développeuse full-stack en devenir · M1 Informatique',
                    helperText:
                        "C'est la première ligne que voient les recruteurs.",
                  ),
                ),
                const SizedBox(height: 8),
                _pair(
                  TextField(
                    controller: _city,
                    onChanged: _form.setCity,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      prefixIcon: Icon(Icons.place_outlined, size: 20),
                    ),
                  ),
                  TextField(
                    key: const ValueKey('profile-email'),
                    controller: _email,
                    onChanged: _form.setEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail de contact',
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        size: 20,
                      ),
                      errorText: _form.visibleErrorFor(ProfileEditField.email),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ------------------------------------------------------------------
        _section(
          ProfileSection.presentation,
          ProfileSectionCard(
            title: 'Présentation',
            child: TextField(
              key: const ValueKey('profile-bio'),
              controller: _bio,
              onChanged: _form.setBio,
              minLines: 4,
              maxLines: 8,
              maxLength: StudentProfile.bioMaxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Quelques mots sur toi',
                helperText: 'Astuce : dis ce que tu sais faire, ce que tu cherches et pourquoi l’alternance. 3 ou 4 phrases suffisent.',
              ),
            ),
          ),
        ),
        // ------------------------------------------------------------------
        _section(
          ProfileSection.education,
          ProfileSectionCard(
            title: 'Formation',
            trailing: TextButton.icon(
              onPressed: _addEducation,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter'),
            ),
            child: draft.educations.isEmpty
                ? const ProfileEmptyHint('Ajoute ta formation actuelle.')
                : Column(
                    children: [
                      for (var i = 0; i < draft.educations.length; i++)
                        ProfileTimelineTile(
                          title: draft.educations[i].title,
                          subtitle: [
                            draft.educations[i].school,
                            draft.educations[i].period,
                          ].where((part) => part.trim().isNotEmpty).join(' · '),
                          tint: AppColors.skyTint,
                          foreground: AppColors.navy,
                          trailing: IconButton(
                            tooltip: 'Retirer cette formation',
                            onPressed: () => _form.removeEducation(i),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        // ------------------------------------------------------------------
        _section(
          ProfileSection.experiences,
          ProfileSectionCard(
            title: 'Expériences',
            trailing: TextButton.icon(
              onPressed: () => setState(() => _experienceFormOpen = true),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (draft.experiences.isEmpty && !_experienceFormOpen)
                  const ProfileEmptyHint(
                    'Stage, job étudiant, projet associatif : tout compte.',
                  ),
                for (var i = 0; i < draft.experiences.length; i++)
                  ProfileTimelineTile(
                    title: draft.experiences[i].title,
                    subtitle: [
                      draft.experiences[i].organization,
                      draft.experiences[i].period,
                    ].where((part) => part.trim().isNotEmpty).join(' · '),
                    tint: AppColors.orangeTint,
                    foreground: AppColors.orangeDeep,
                    description: draft.experiences[i].description,
                    trailing: IconButton(
                      tooltip: 'Retirer cette expérience',
                      onPressed: () => _form.removeExperience(i),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                  ),
                if (_experienceFormOpen) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: const ValueKey('profile-new-role'),
                            controller: _newRole,
                            autofocus: true,
                            onChanged: (_) {
                              if (_experienceAttempted) setState(() {});
                            },
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Poste',
                              hintText: 'Stage développeuse web',
                              errorText:
                                  _experienceAttempted &&
                                      _newRole.text.trim().isEmpty
                                  ? 'Indique le poste.'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _pair(
                            TextField(
                              key: const ValueKey('profile-new-organization'),
                              controller: _newOrganization,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Entreprise',
                                hintText: 'Entreprise X',
                              ),
                            ),
                            TextField(
                              key: const ValueKey('profile-new-period'),
                              controller: _newPeriod,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Dates',
                                hintText: 'juin – août 2026 · 3 mois',
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            key: const ValueKey('profile-new-description'),
                            controller: _newDescription,
                            minLines: 3,
                            maxLines: 6,
                            maxLength: 300,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              alignLabelWithHint: true,
                              labelText: 'Description (facultatif)',
                              hintText: "Ce que tu as fait, les technos utilisées, un résultat chiffré…",
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    setState(() => _experienceFormOpen = false),
                                child: const Text('Annuler'),
                              ),
                              FilledButton(
                                onPressed: _addExperience,
                                child: const Text("Ajouter l'expérience"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // ------------------------------------------------------------------
        _section(
          ProfileSection.skills,
          ProfileSectionCard(
            title: 'Compétences',
            subtitle: 'Touche une compétence pour changer son niveau.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < draft.skills.length; i++)
                      _SkillChip(
                        skill: draft.skills[i],
                        onCycle: () => _form.cycleSkillLevel(i),
                        onRemove: () => _form.removeSkill(i),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('profile-new-skill'),
                  controller: _newSkill,
                  onSubmitted: (_) => _addSkill(),
                  decoration: InputDecoration(
                    labelText: 'Ajouter une compétence',
                    hintText: 'Kotlin, Figma…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: IconButton(
                      tooltip: 'Ajouter',
                      onPressed: _addSkill,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                ),
                if (_form.suggestedSkills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Suggérées par tes offres :',
                        style: textTheme.bodySmall,
                      ),
                      for (final name in _form.suggestedSkills)
                        ActionChip(
                          avatar: const Icon(Icons.add_rounded, size: 16),
                          label: Text(name),
                          onPressed: () => _addSkill(name),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        // ------------------------------------------------------------------
        _section(
          ProfileSection.links,
          ProfileSectionCard(
            title: 'Liens et CV',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _github,
                  onChanged: _form.setGithub,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'GitHub',
                    hintText: 'github.com/pseudo',
                    prefixIcon: Icon(Icons.code_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _linkedin,
                  onChanged: _form.setLinkedin,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn',
                    hintText: 'linkedin.com/in/pseudo',
                    prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _portfolio,
                  onChanged: _form.setPortfolio,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Portfolio',
                    hintText: 'mon-portfolio.dev',
                    prefixIcon: Icon(Icons.language_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                if (draft.cv case final cv?)
                  CvFileTile(cv: cv, onReplace: _pickCv)
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _pickCv,
                      icon: const Icon(Icons.upload_file_rounded, size: 20),
                      label: const Text('Importer mon CV'),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Ton CV est envoyé automatiquement avec chaque candidature.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        // ------------------------------------------------------------------
        _section(
          ProfileSection.availability,
          ProfileSectionCard(
            title: 'Disponibilité',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _pair(
                  DropdownMenu<String>(
                    expandedInsets: EdgeInsets.zero,
                    requestFocusOnTap: false,
                    label: const Text('Début'),
                    initialSelection: draft.availability.start.isEmpty
                        ? null
                        : draft.availability.start,
                    onSelected: (value) {
                      if (value != null) _form.setStart(value);
                    },
                    dropdownMenuEntries: [
                      for (final start in {
                        ...ProfileOptions.startDates,
                        if (draft.availability.start.isNotEmpty)
                          draft.availability.start,
                      })
                        DropdownMenuEntry(value: start, label: start),
                    ],
                  ),
                  DropdownMenu<int>(
                    expandedInsets: EdgeInsets.zero,
                    requestFocusOnTap: false,
                    label: const Text('Durée'),
                    initialSelection: draft.availability.durationMonths,
                    onSelected: (value) {
                      if (value != null) _form.setDuration(value);
                    },
                    dropdownMenuEntries: [
                      for (final months in ProfileOptions.durations)
                        DropdownMenuEntry(value: months, label: '$months mois'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Rythme', style: textTheme.titleSmall),
                const SizedBox(height: 10),
                JoynChipGroup<String>.single(
                  options: ProfileOptions.rhythms,
                  selected: draft.availability.rhythm,
                  onSelected: _form.setRhythm,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Trajet maximum',
                        style: textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      '${draft.availability.maxCommuteMinutes} min',
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: draft.availability.maxCommuteMinutes.toDouble(),
                  min: 10,
                  max: 90,
                  divisions: 16,
                  label: '${draft.availability.maxCommuteMinutes} min',
                  semanticFormatterCallback: (value) =>
                      '${value.round()} minutes de trajet maximum',
                  onChanged: (value) => _form.setMaxCommute(value.round()),
                ),
              ],
            ),
          ),
        ),
        // ------------------------------------------------------------------
        _section(
          ProfileSection.visibility,
          ProfileSectionCard(
            title: 'Visibilité',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: draft.visibility.visibleToRecruiters,
                  onChanged: _form.setVisibleToRecruiters,
                  title: const Text('Profil visible des recruteurs'),
                  subtitle: const Text(
                    'Sinon, seules les entreprises avec qui tu matches te voient.',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: draft.visibility.hiddenFromCurrentEmployer,
                  onChanged: _form.setHiddenFromCurrentEmployer,
                  title: const Text(
                    'Masquer mon profil à mon entreprise actuelle',
                  ),
                  subtitle: const Text('Pour chercher en toute discrétion.'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: draft.visibility.openToReplacement,
                  onChanged: _form.setOpenToReplacement,
                  title: const Text(
                    'Ouvert·e aux propositions « Remplace-moi »',
                  ),
                  subtitle: const Text(
                    'Les alternant·e·s peuvent te recommander pour leur poste.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compétence modifiable : un appui change le niveau, la croix la retire.
class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.skill,
    required this.onCycle,
    required this.onRemove,
  });

  final ProfileSkill skill;
  final VoidCallback onCycle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final advanced = skill.level == ProfileSkillLevel.advanced;
    final foreground = advanced ? AppColors.white : AppColors.navy;

    return Tooltip(
      message: 'Niveau suivant : ${skill.level.next.label.toLowerCase()}',
      child: InputChip(
        label: Text('${skill.name} · ${skill.level.label.toLowerCase()}'),
        labelStyle: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground),
        color: WidgetStatePropertyAll(
          advanced ? AppColors.navy : AppColors.skyTint,
        ),
        side: BorderSide.none,
        deleteIconColor: foreground,
        deleteButtonTooltipMessage: 'Retirer ${skill.name}',
        onPressed: onCycle,
        onDeleted: onRemove,
      ),
    );
  }
}
