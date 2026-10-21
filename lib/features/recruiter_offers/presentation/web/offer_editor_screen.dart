import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_pill.dart';
import '../../../../design_system/components/joyn_removable_chip.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_gradients.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../domain/job_offer.dart';
import '../../domain/offer_options.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_editor_controller.dart';
import '../shared/offer_ui.dart';
import 'company_picker_drawer.dart';
import 'recruiter_offers_top_bar.dart';

class WebOfferEditorScreen extends StatefulWidget {
  const WebOfferEditorScreen({super.key});

  @override
  State<WebOfferEditorScreen> createState() => _WebOfferEditorScreenState();
}

class _WebOfferEditorScreenState extends State<WebOfferEditorScreen> {
  final _skillController = TextEditingController();

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OfferEditorController>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1020;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Container(height: 300, decoration: const BoxDecoration(gradient: AppGradients.hero)),
                const Expanded(child: ColoredBox(color: AppColors.background)),
              ],
            ),
          ),
          SafeArea(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(width < 760 ? 18 : 28, 16, width < 760 ? 18 : 28, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1220),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const RecruiterOffersTopBar(),
                            const SizedBox(height: 28),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.isEditing ? 'Modifier l’offre' : 'Créer une offre',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: AppFonts.display,
                                          fontSize: 34,
                                          height: 1,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -.8,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        controller.isEditing
                                            ? 'Mettez à jour les informations puis enregistrez vos changements.'
                                            : 'Attirez les meilleurs talents en quelques minutes. Remplissez les informations ci-dessous pour publier votre offre.',
                                        style: const TextStyle(color: Color(0xFFE4F3FB), fontSize: 13, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => context.go(AppRoutes.recruiterJobs),
                                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                                  label: const Text('Mes offres', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            if (controller.submitError != null) ...[
                              _ErrorBanner(message: controller.submitError!),
                              const SizedBox(height: 14),
                            ],
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 7, child: _formColumn(controller)),
                                  const SizedBox(width: 18),
                                  Expanded(flex: 3, child: _previewColumn(controller)),
                                ],
                              )
                            else ...[
                              _formColumn(controller),
                              const SizedBox(height: 18),
                              _previewColumn(controller),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _formColumn(OfferEditorController controller) => Column(
    children: [
      _companySection(controller),
      const SizedBox(height: 12),
      _mainSection(controller),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: controller.isWorkStudy
            ? Padding(padding: const EdgeInsets.only(top: 12), child: _workStudySection(controller))
            : const SizedBox.shrink(),
      ),
      const SizedBox(height: 12),
      _descriptionSection(controller),
      const SizedBox(height: 12),
      _skillsSection(controller),
      const SizedBox(height: 12),
      _salarySection(controller),
      const SizedBox(height: 16),
      _actions(controller),
    ],
  );

  Widget _companySection(OfferEditorController controller) => _WebCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle(title: 'Choisir une entreprise *', subtitle: 'Sélectionnez l’entreprise disponible dans la base pour laquelle vous souhaitez publier cette offre.'),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, constraints) {
        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            for (final company in controller.companies)
              _CompanyChoice(
                company: company,
                selected: controller.selectedCompany?.id == company.id,
                onTap: () => controller.selectCompany(company),
              ),
            _AddCompanyChoice(onTap: () => showCompanyPickerDrawer(context, controller)),
          ],
        );
      }),
      if (controller.errors['company'] != null) ...[
        const SizedBox(height: 8),
        Text(controller.errors['company']!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ]),
  );

  Widget _mainSection(OfferEditorController controller) => _WebCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle(title: 'Informations principales', subtitle: 'Ces informations seront visibles par les candidats sur votre offre.'),
      const SizedBox(height: 16),
      _ResponsiveFields(children: [
        _Field(
          label: 'Intitulé du poste *',
          error: controller.errors['title'],
          child: TextFormField(
            key: ValueKey('title-${controller.editingOffer?.id ?? 'new'}'),
            initialValue: controller.title,
            onChanged: controller.updateTitle,
            decoration: _inputDecoration('Développeur·se Full-Stack en alternance'),
          ),
        ),
        _Field(
          label: 'Type de contrat *',
          child: DropdownButtonFormField<ContractType>(
            initialValue: controller.contractType,
            items: ContractType.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(),
            onChanged: (value) { if (value != null) controller.updateContractType(value); },
            decoration: _inputDecoration('Type de contrat', icon: Icons.work_outline_rounded),
          ),
        ),
        _Field(
          label: 'Localisation *',
          error: controller.errors['location'],
          child: TextFormField(
            key: ValueKey('location-${controller.editingOffer?.id ?? 'new'}'),
            initialValue: controller.location,
            onChanged: controller.updateLocation,
            decoration: _inputDecoration('Paris, France', icon: Icons.location_on_outlined),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _SegmentSection<RemoteMode>(
          label: 'Mode de travail *',
          values: RemoteMode.values,
          selected: controller.remoteMode,
          labelOf: (value) => value.label,
          iconOf: (value) => switch (value) { RemoteMode.onsite => Icons.apartment_rounded, RemoteMode.hybrid => Icons.laptop_mac_rounded, RemoteMode.remote => Icons.home_outlined },
          onSelected: controller.updateRemoteMode,
        )),
        const SizedBox(width: 14),
        Expanded(child: _SegmentSection<ExperienceLevel>(
          label: 'Niveau d’expérience *',
          values: ExperienceLevel.values,
          selected: controller.experienceLevel,
          labelOf: (value) => value.label,
          iconOf: (value) => Icons.bar_chart_rounded,
          onSelected: controller.updateExperienceLevel,
        )),
      ]),
    ]),
  );

  Widget _workStudySection(OfferEditorController controller) => _WebCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle(title: 'Détails de l’alternance', subtitle: 'Précisez les modalités du contrat en alternance.'),
      const SizedBox(height: 15),
      _ResponsiveFields(children: [
        _Field(label: 'Rythme *', child: DropdownButtonFormField<String>(initialValue: controller.rhythmType, items: OfferOptions.rhythms.map((value) => DropdownMenuItem(value: value, child: Text(value, overflow: TextOverflow.ellipsis))).toList(), onChanged: (value) { if (value != null) controller.updateRhythm(value); }, decoration: _inputDecoration('Rythme', icon: Icons.calendar_view_week_outlined))),
        _Field(label: 'Date de début *', child: _DateField(value: controller.startDate, onChanged: controller.updateStartDate)),
        _Field(label: 'Durée *', error: controller.errors['duration'], child: TextFormField(key: ValueKey('duration-${controller.editingOffer?.id ?? 'new'}'), initialValue: controller.durationMonths?.toString() ?? '', onChanged: controller.updateDuration, keyboardType: TextInputType.number, decoration: _inputDecoration('12 mois', icon: Icons.schedule_rounded, suffix: 'mois'))),
        _Field(label: 'Niveau d’études requis *', child: DropdownButtonFormField<String>(initialValue: controller.degreeLevelRequired, items: OfferOptions.degreeLevels.map((value) => DropdownMenuItem(value: value, child: Text(_degreeLabel(value)))).toList(), onChanged: (value) { if (value != null) controller.updateDegree(value); }, decoration: _inputDecoration('Bac+5', icon: Icons.school_outlined))),
      ], minItemWidth: 150),
    ]),
  );

  Widget _descriptionSection(OfferEditorController controller) => _WebCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle(title: 'Description, missions et profil recherché *', subtitle: 'Présentez le poste, les missions principales et le profil idéal.'),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: controller.errors['description'] == null ? AppColors.line : AppColors.error), color: Colors.white),
        child: Column(children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.lineSoft))),
            child: const Row(children: [
              _ToolbarIcon(Icons.format_bold_rounded), _ToolbarIcon(Icons.format_italic_rounded), _ToolbarIcon(Icons.format_list_bulleted_rounded), _ToolbarIcon(Icons.format_list_numbered_rounded), _ToolbarIcon(Icons.link_rounded), Spacer(), Text('0/5000', style: TextStyle(color: AppColors.placeholder, fontSize: 10)),
            ]),
          ),
          TextFormField(
            key: ValueKey('description-${controller.editingOffer?.id ?? 'new'}'),
            initialValue: controller.description,
            minLines: 5,
            maxLines: 8,
            onChanged: controller.updateDescription,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(14), hintText: 'Décrivez le poste, l’environnement de travail et le profil recherché...'),
          ),
        ]),
      ),
      if (controller.errors['description'] != null) ...[
        const SizedBox(height: 7),
        Text(controller.errors['description']!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ]),
  );

  Widget _skillsSection(OfferEditorController controller) => _WebCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle(title: 'Compétences recherchées', subtitle: 'Ajoutez les compétences clés. Au moins une compétence est requise.'),
      const SizedBox(height: 13),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _skillController,
            onSubmitted: (_) => _addSkill(controller),
            decoration: _inputDecoration('Ajouter une compétence (ex : React, Figma, management...)', icon: Icons.search_rounded),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 46,
          height: 46,
          child: IconButton.filledTonal(
            onPressed: () => _addSkill(controller),
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFEAF4FC), foregroundColor: const Color(0xFF1976D2)),
          ),
        ),
      ]),
      const SizedBox(height: 11),
      Wrap(spacing: 8, runSpacing: 8, children: controller.skills.map((skill) => JoynRemovableChip(label: skill, onRemove: () => controller.removeSkill(skill))).toList()),
      if (controller.errors['skills'] != null) ...[
        const SizedBox(height: 8),
        Text(controller.errors['skills']!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
      const SizedBox(height: 11),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: OfferOptions.skills.where((item) => !controller.skills.any((s) => s.toLowerCase() == item.toLowerCase())).take(5).map((skill) => ActionChip(label: Text(skill), onPressed: () => controller.addSkill(skill), backgroundColor: const Color(0xFFF5F8FB), side: const BorderSide(color: AppColors.lineSoft), labelStyle: const TextStyle(color: AppColors.slateDark, fontSize: 10, fontWeight: FontWeight.w600))).toList(),
      ),
    ]),
  );

  Widget _salarySection(OfferEditorController controller) => _WebCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle(title: 'Rémunération', subtitle: 'Indiquez la fourchette de rémunération proposée.'),
      const SizedBox(height: 15),
      _ResponsiveFields(children: [
        _Field(label: 'Salaire minimum', child: TextFormField(key: ValueKey('min-${controller.editingOffer?.id ?? 'new'}'), initialValue: controller.salaryMin?.toStringAsFixed(0) ?? '', onChanged: controller.updateSalaryMin, keyboardType: TextInputType.number, decoration: _inputDecoration('1 200', suffix: '€'))),
        _Field(label: 'Salaire maximum', child: TextFormField(key: ValueKey('max-${controller.editingOffer?.id ?? 'new'}'), initialValue: controller.salaryMax?.toStringAsFixed(0) ?? '', onChanged: controller.updateSalaryMax, keyboardType: TextInputType.number, decoration: _inputDecoration('1 800', suffix: '€'))),
        _Field(label: 'Devise', child: DropdownButtonFormField<String>(initialValue: controller.currency, items: const ['EUR', 'CHF', 'GBP', 'USD'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) { if (value != null) controller.updateCurrency(value); }, decoration: _inputDecoration('EUR'))),
        _Field(label: 'Période', child: DropdownButtonFormField<SalaryPeriod>(initialValue: controller.salaryPeriod, items: SalaryPeriod.values.map((value) => DropdownMenuItem(value: value, child: Text(value.label))).toList(), onChanged: (value) { if (value != null) controller.updateSalaryPeriod(value); }, decoration: _inputDecoration('Mensuel'))),
      ], minItemWidth: 145),
      if (controller.errors['salary'] != null) ...[
        const SizedBox(height: 8),
        Text(controller.errors['salary']!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ]),
  );

  Widget _actions(OfferEditorController controller) {
    if (controller.isEditing) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        JoynButton(label: 'Annuler', variant: JoynButtonVariant.outline, height: 50, onPressed: () => context.go(AppRoutes.recruiterJobs)),
        const SizedBox(width: 10),
        JoynButton(label: 'Enregistrer les modifications', variant: JoynButtonVariant.accent, leadingIcon: Icons.save_outlined, height: 50, isLoading: controller.isSubmitting, onPressed: () => _submit(controller, JobOfferStatus.published)),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      JoynButton(label: 'Enregistrer en brouillon', variant: JoynButtonVariant.outline, leadingIcon: Icons.description_outlined, height: 50, isLoading: controller.isSubmitting, onPressed: () => _submit(controller, JobOfferStatus.draft)),
      const SizedBox(width: 10),
      JoynButton(label: 'Publier l’offre', variant: JoynButtonVariant.accent, leadingIcon: Icons.send_rounded, height: 50, isLoading: controller.isSubmitting, onPressed: () => _submit(controller, JobOfferStatus.published)),
    ]);
  }

  Widget _previewColumn(OfferEditorController controller) {
    final company = controller.selectedCompany ?? (controller.companies.isEmpty ? null : controller.companies.first);
    if (company == null) return const SizedBox.shrink();
    final preview = JobOffer(
      id: controller.offerId ?? 0,
      companyId: company.id,
      title: controller.title.trim().isEmpty ? 'Intitulé de votre offre' : controller.title.trim(),
      contractType: controller.contractType,
      location: controller.location.trim().isEmpty ? 'Localisation' : controller.location.trim(),
      remoteMode: controller.remoteMode,
      experienceLevel: controller.experienceLevel,
      description: controller.description.trim().isEmpty ? 'Votre description apparaîtra ici.' : controller.description.trim(),
      salaryMin: controller.salaryMin,
      salaryMax: controller.salaryMax,
      currency: controller.currency,
      salaryPeriod: controller.salaryPeriod,
      skills: controller.skills,
      rhythmType: controller.isWorkStudy ? controller.rhythmType : null,
      startDate: controller.isWorkStudy ? controller.startDate : null,
      durationMonths: controller.isWorkStudy ? controller.durationMonths : null,
      degreeLevelRequired: controller.isWorkStudy ? controller.degreeLevelRequired : null,
      status: controller.editingOffer?.status ?? JobOfferStatus.draft,
      updatedAt: DateTime.now(),
    );
    return _WebCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Aperçu de l’offre', style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 3),
            Text('Voici un aperçu de la façon dont votre offre sera affichée aux candidats.', style: TextStyle(color: AppColors.slate, fontSize: 10, height: 1.35)),
          ]),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: OfferPreviewCard(key: ValueKey('${preview.title}-${preview.skills.length}-${company.id}-${preview.salaryMin}-${preview.salaryMax}'), offer: preview, company: company),
        ),
      ]),
    );
  }

  void _addSkill(OfferEditorController controller) {
    if (controller.addSkill(_skillController.text)) _skillController.clear();
  }

  Future<void> _submit(OfferEditorController controller, JobOfferStatus status) async {
    final result = await controller.submit(status);
    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.isEditing ? 'Offre mise à jour.' : status == JobOfferStatus.draft ? 'Brouillon enregistré.' : 'Offre publiée.'), behavior: SnackBarBehavior.floating));
    context.go(AppRoutes.recruiterJobs);
  }
}

class _WebCard extends StatelessWidget {
  const _WebCard({required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.lineSoft), boxShadow: AppShadows.card),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    Text(subtitle, style: const TextStyle(color: AppColors.slate, fontSize: 10, height: 1.35)),
  ]);
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.error});
  final String label;
  final Widget child;
  final String? error;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text(label, style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w800)),
    const SizedBox(height: 6),
    child,
    if (error != null) ...[
      const SizedBox(height: 5),
      Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700)),
    ],
  ]);
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children, this.minItemWidth = 190});
  final List<Widget> children;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final maxPerRow = (constraints.maxWidth / minItemWidth).floor().clamp(1, children.length);
    final gap = 10.0;
    final itemWidth = (constraints.maxWidth - gap * (maxPerRow - 1)) / maxPerRow;
    return Wrap(spacing: gap, runSpacing: 12, children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList());
  });
}

class _SegmentSection<T> extends StatelessWidget {
  const _SegmentSection({required this.label, required this.values, required this.selected, required this.labelOf, required this.iconOf, required this.onSelected});
  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T) iconOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text(label, style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w800)),
    const SizedBox(height: 6),
    Row(children: values.map((value) {
      final active = value == selected;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: value == values.last ? 0 : 6),
          child: Material(
            color: active ? const Color(0xFFEAF4FC) : Colors.white,
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              onTap: () => onSelected(value),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), border: Border.all(color: active ? AppColors.blue : AppColors.lineSoft, width: active ? 1.4 : 1)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(iconOf(value), size: 15, color: active ? const Color(0xFF1976D2) : AppColors.slate),
                  const SizedBox(width: 5),
                  Flexible(child: Text(labelOf(value), overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? const Color(0xFF1976D2) : AppColors.slate, fontSize: 10, fontWeight: active ? FontWeight.w800 : FontWeight.w600))),
                ]),
              ),
            ),
          ),
        ),
      );
    }).toList()),
  ]);
}

class _CompanyChoice extends StatelessWidget {
  const _CompanyChoice({required this.company, required this.selected, required this.onTap});
  final RecruiterCompany company;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: company.name,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 138,
          height: 66,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: selected ? AppColors.orange : AppColors.lineSoft, width: selected ? 1.5 : 1),
            boxShadow: selected ? [const BoxShadow(color: Color(0x22FF6731), blurRadius: 14)] : null,
          ),
          child: Row(children: [
            CompanyAvatar(company: company, size: 37),
            const SizedBox(width: 9),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(company.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w900)),
              Text(company.activity, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.slate, fontSize: 8)),
            ])),
            if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFF1976D2), size: 17),
          ]),
        ),
      ),
    ),
  );
}

class _AddCompanyChoice extends StatelessWidget {
  const _AddCompanyChoice({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      width: 138,
      height: 66,
      decoration: BoxDecoration(color: const Color(0xFFF8FBFD), borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.blue.withValues(alpha: .65))),
      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.add_rounded, color: Color(0xFF1976D2), size: 20),
        SizedBox(height: 3),
        Text('Créer une entreprise', style: TextStyle(color: Color(0xFF1976D2), fontSize: 9, fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onChanged});
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final now = DateTime.now();
      final picked = await showDatePicker(context: context, initialDate: value ?? DateTime(now.year, now.month, now.day), firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 8), locale: const Locale('fr', 'FR'));
      if (picked != null) onChanged(picked);
    },
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: _inputDecoration('Date de début', icon: Icons.calendar_month_outlined),
      child: Text(monthYearLabel(value), style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w600)),
    ),
  );
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 10), child: Icon(icon, color: AppColors.slateDark, size: 16));
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: AppColors.errorTint, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x33E24B4B))),
    child: Row(children: [const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 19), const SizedBox(width: 9), Expanded(child: Text(message, style: const TextStyle(color: AppColors.errorDeep, fontSize: 12, fontWeight: FontWeight.w700)))]),
  );
}

InputDecoration _inputDecoration(String hint, {IconData? icon, String? suffix}) => InputDecoration(
  hintText: hint,
  prefixIcon: icon == null ? null : Icon(icon, size: 18, color: const Color(0xFF1976D2)),
  suffixText: suffix,
  filled: true,
  fillColor: Colors.white,
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lineSoft)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lineSoft)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
);

String _degreeLabel(String value) => switch (value) {
  'BAC_2' => 'Bac+2',
  'BAC_3' => 'Bac+3',
  'BAC_4' => 'Bac+4',
  _ => 'Bac+5',
};
