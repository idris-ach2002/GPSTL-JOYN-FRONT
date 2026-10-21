import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/job_offer.dart';
import '../../domain/offer_options.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_editor_controller.dart';
import '../shared/offer_ui.dart';
import 'mobile_company_picker_sheet.dart';

class MobileOfferEditorScreen extends StatefulWidget {
  const MobileOfferEditorScreen({super.key});

  @override
  State<MobileOfferEditorScreen> createState() => _MobileOfferEditorScreenState();
}

class _MobileOfferEditorScreenState extends State<MobileOfferEditorScreen> {
  final _skill = TextEditingController();

  @override
  void dispose() {
    _skill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OfferEditorController>();
    return MobileAppSurface(
      backgroundColor: Colors.white,
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(controller),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(.035, 0), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    ),
                    child: SingleChildScrollView(
                      key: ValueKey(controller.mobileStep),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: _step(controller),
                    ),
                  ),
                ),
                _footer(controller),
              ],
            ),
    );
  }

  Widget _header(OfferEditorController controller) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 14, 8),
    child: Column(children: [
      Row(children: [
        IconButton(
          onPressed: controller.mobileStep == 0
              ? () => context.go(AppRoutes.recruiterJobs)
              : controller.previousMobileStep,
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
        ),
        const Spacer(),
        const MobileBrandMark(compact: true),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFE7EDF3), borderRadius: BorderRadius.circular(5)),
          child: Text(controller.isEditing ? 'Modification' : 'Recruteur', style: const TextStyle(color: AppColors.slateDark, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        SizedBox(width: 48, child: Text('${controller.mobileStep + 1}/5', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w800))),
      ]),
      const SizedBox(height: 8),
      Row(children: List.generate(5, (index) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 4,
            decoration: BoxDecoration(color: index <= controller.mobileStep ? AppColors.blue : AppColors.track, borderRadius: BorderRadius.circular(99)),
          ),
        ),
      ))),
    ]),
  );

  Widget _step(OfferEditorController controller) => switch (controller.mobileStep) {
    0 => _companyStep(controller),
    1 => _jobStep(controller),
    2 => _descriptionStep(controller),
    3 => _skillsSalaryStep(controller),
    _ => _reviewStep(controller),
  };

  Widget _title(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 26, height: 1, fontWeight: FontWeight.w900, letterSpacing: -.7)),
    const SizedBox(height: 7),
    Text(subtitle, style: const TextStyle(color: AppColors.slate, fontSize: 13, height: 1.4)),
    const SizedBox(height: 22),
  ]);

  Widget _companyStep(OfferEditorController controller) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _title('Entreprise', 'Sélectionnez l’entreprise de la base pour laquelle vous souhaitez publier cette offre.'),
    SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.companies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final company = controller.companies[index];
          final selected = controller.selectedCompany?.id == company.id;
          return _MobileCompanyChoice(company: company, selected: selected, onTap: () => controller.selectCompany(company));
        },
      ),
    ),
    const SizedBox(height: 16),
    InkWell(
      onTap: () => showMobileCompanyPicker(context, controller),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 118,
        decoration: BoxDecoration(color: const Color(0xFFF8FBFD), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.blue.withValues(alpha: .65))),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_rounded, color: Color(0xFF1976D2), size: 30), SizedBox(height: 8), Text('Créer une entreprise', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w900))]),
      ),
    ),
    if (controller.errors['company'] != null) ...[
      const SizedBox(height: 9),
      Text(controller.errors['company']!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
    ],
    const SizedBox(height: 22),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFEAF4FC), borderRadius: BorderRadius.circular(16)),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_rounded, color: Color(0xFF1976D2), size: 19),
        SizedBox(width: 10),
        Expanded(child: Text('Vous ne trouvez pas votre entreprise ? Recherchez-la par SIRET ou créez-la pour poursuivre.', style: TextStyle(color: AppColors.slateDark, fontSize: 11, height: 1.4, fontWeight: FontWeight.w600))),
      ]),
    ),
  ]);

  Widget _jobStep(OfferEditorController controller) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _title('Informations du poste', 'Ces informations seront visibles par les candidats sur votre offre.'),
    MobileField(label: 'Intitulé du poste *', initialValue: controller.title, onChanged: controller.updateTitle, validator: (_) => controller.errors['title']),
    _error(controller.errors['title']),
    const SizedBox(height: 14),
    _Dropdown<ContractType>(label: 'Type de contrat *', value: controller.contractType, values: ContractType.values, labelOf: (value) => value.label, onChanged: controller.updateContractType),
    const SizedBox(height: 14),
    MobileField(label: 'Localisation *', initialValue: controller.location, onChanged: controller.updateLocation),
    _error(controller.errors['location']),
    const SizedBox(height: 16),
    const Text('Mode de travail *', style: _labelStyle),
    const SizedBox(height: 8),
    _MobileSegments<RemoteMode>(values: RemoteMode.values, selected: controller.remoteMode, labelOf: (value) => value.label, iconOf: (value) => switch (value) { RemoteMode.onsite => Icons.apartment_rounded, RemoteMode.hybrid => Icons.laptop_mac_rounded, RemoteMode.remote => Icons.home_outlined }, onSelected: controller.updateRemoteMode),
    const SizedBox(height: 16),
    const Text('Niveau d’expérience *', style: _labelStyle),
    const SizedBox(height: 8),
    _MobileSegments<ExperienceLevel>(values: ExperienceLevel.values, selected: controller.experienceLevel, labelOf: (value) => value.label, iconOf: (_) => Icons.bar_chart_rounded, onSelected: controller.updateExperienceLevel),
    AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: controller.isWorkStudy ? Padding(padding: const EdgeInsets.only(top: 18), child: _mobileWorkStudy(controller)) : const SizedBox.shrink(),
    ),
  ]);

  Widget _mobileWorkStudy(OfferEditorController controller) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: const Color(0xFFF3F8FC), borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Row(children: [Icon(Icons.calendar_month_rounded, color: Color(0xFF1976D2), size: 18), SizedBox(width: 8), Text('Détails de l’alternance', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 14),
      _Dropdown<String>(label: 'Rythme *', value: controller.rhythmType, values: OfferOptions.rhythms, labelOf: (value) => value, onChanged: controller.updateRhythm),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _MobileDateField(value: controller.startDate, onChanged: controller.updateStartDate)),
        const SizedBox(width: 10),
        Expanded(child: MobileField(label: 'Durée *', initialValue: controller.durationMonths?.toString() ?? '', keyboardType: TextInputType.number, onChanged: controller.updateDuration)),
      ]),
      _error(controller.errors['duration']),
      const SizedBox(height: 12),
      _Dropdown<String>(label: 'Niveau d’études requis *', value: controller.degreeLevelRequired, values: OfferOptions.degreeLevels, labelOf: _degreeLabel, onChanged: controller.updateDegree),
    ]),
  );

  Widget _descriptionStep(OfferEditorController controller) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _title('Description du poste', 'Présentez les missions, l’environnement de travail et le profil recherché.'),
    const Text('Description, missions et profil recherché *', style: _labelStyle),
    const SizedBox(height: 8),
    TextFormField(
      initialValue: controller.description,
      onChanged: controller.updateDescription,
      minLines: 12,
      maxLines: 18,
      decoration: InputDecoration(hintText: 'Décrivez le poste et le profil idéal…', filled: true, fillColor: const Color(0xFFF6F8F6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE4E8E3))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFE4E8E3))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.orange, width: 1.4))),
    ),
    _error(controller.errors['description']),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.orangeMist, borderRadius: BorderRadius.circular(16)),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.lightbulb_outline_rounded, color: AppColors.orange, size: 19),
        SizedBox(width: 9),
        Expanded(child: Text('Soyez concret : missions, stack, équipe, responsabilités et ce qui rend le poste attractif.', style: TextStyle(color: AppColors.slateDark, fontSize: 11, height: 1.4, fontWeight: FontWeight.w600))),
      ]),
    ),
  ]);

  Widget _skillsSalaryStep(OfferEditorController controller) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _title('Compétences & rémunération', 'Ajoutez les compétences clés et la fourchette de salaire.'),
    const Text('Compétences recherchées *', style: _labelStyle),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(child: TextField(controller: _skill, onSubmitted: (_) => _addSkill(controller), decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'React, Java, Figma…', filled: true, fillColor: const Color(0xFFF4F6F3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE4E8E3))))))),
      const SizedBox(width: 8),
      SizedBox(width: 54, height: 54, child: FilledButton(onPressed: () => _addSkill(controller), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEAF4FC), foregroundColor: const Color(0xFF1976D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Icon(Icons.add_rounded))),
    ]),
    const SizedBox(height: 10),
    Wrap(spacing: 7, runSpacing: 7, children: controller.skills.map((skill) => InputChip(label: Text(skill), onDeleted: () => controller.removeSkill(skill), backgroundColor: const Color(0xFFEAF4FC), deleteIconColor: const Color(0xFF1976D2), labelStyle: const TextStyle(color: Color(0xFF1976D2), fontSize: 11, fontWeight: FontWeight.w700), side: BorderSide.none)).toList()),
    _error(controller.errors['skills']),
    const SizedBox(height: 20),
    const Text('Rémunération', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: MobileField(label: 'Minimum', initialValue: controller.salaryMin?.toStringAsFixed(0) ?? '', keyboardType: TextInputType.number, onChanged: controller.updateSalaryMin)),
      const SizedBox(width: 10),
      Expanded(child: MobileField(label: 'Maximum', initialValue: controller.salaryMax?.toStringAsFixed(0) ?? '', keyboardType: TextInputType.number, onChanged: controller.updateSalaryMax)),
    ]),
    _error(controller.errors['salary']),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _Dropdown<String>(label: 'Devise', value: controller.currency, values: const ['EUR', 'CHF', 'GBP', 'USD'], labelOf: (value) => value, onChanged: controller.updateCurrency)),
      const SizedBox(width: 10),
      Expanded(child: _Dropdown<SalaryPeriod>(label: 'Période', value: controller.salaryPeriod, values: SalaryPeriod.values, labelOf: (value) => value.label, onChanged: controller.updateSalaryPeriod)),
    ]),
  ]);

  Widget _reviewStep(OfferEditorController controller) {
    final company = controller.selectedCompany ?? (controller.companies.isEmpty ? null : controller.companies.first);
    if (company == null) return _companyStep(controller);
    final preview = JobOffer(
      id: controller.offerId ?? 0,
      companyId: company.id,
      title: controller.title,
      contractType: controller.contractType,
      location: controller.location,
      remoteMode: controller.remoteMode,
      experienceLevel: controller.experienceLevel,
      description: controller.description,
      salaryMin: controller.salaryMin,
      salaryMax: controller.salaryMax,
      currency: controller.currency,
      salaryPeriod: controller.salaryPeriod,
      skills: controller.skills,
      rhythmType: controller.rhythmType,
      startDate: controller.startDate,
      durationMonths: controller.durationMonths,
      degreeLevelRequired: controller.degreeLevelRequired,
      status: controller.editingOffer?.status ?? JobOfferStatus.draft,
      updatedAt: DateTime.now(),
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _title('Vérification', controller.isEditing ? 'Vérifiez vos modifications avant de les enregistrer.' : 'Vérifiez les informations de votre offre avant la publication.'),
      Row(children: [const Expanded(child: Text('Aperçu de l’offre', style: TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w900))), TextButton.icon(onPressed: () => controller.jumpToMobileStep(1), icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Modifier'))]),
      const SizedBox(height: 8),
      OfferPreviewCard(offer: preview, company: company, compact: true),
    ]);
  }

  Widget _footer(OfferEditorController controller) {
    if (controller.mobileStep < 4) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE9ECE8)))),
        child: MobilePrimaryButton(label: 'Continuer', backgroundColor: AppColors.orange, onPressed: controller.nextMobileStep),
      );
    }
    if (controller.isEditing) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE9ECE8)))),
        child: MobilePrimaryButton(label: 'Enregistrer les modifications', icon: Icons.save_outlined, loading: controller.isSubmitting, backgroundColor: AppColors.orange, onPressed: () => _submit(controller, JobOfferStatus.published)),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE9ECE8)))),
      child: Column(children: [
        SizedBox(height: 52, width: double.infinity, child: OutlinedButton.icon(onPressed: controller.isSubmitting ? null : () => _submit(controller, JobOfferStatus.draft), icon: const Icon(Icons.description_outlined), label: const Text('Enregistrer en brouillon'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.navy, side: const BorderSide(color: AppColors.navy), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))))),
        const SizedBox(height: 9),
        MobilePrimaryButton(label: 'Publier l’offre', icon: Icons.send_rounded, loading: controller.isSubmitting, backgroundColor: AppColors.orange, onPressed: () => _submit(controller, JobOfferStatus.published)),
      ]),
    );
  }

  Widget _error(String? message) => message == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 6), child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)));

  void _addSkill(OfferEditorController controller) {
    if (controller.addSkill(_skill.text)) _skill.clear();
  }

  Future<void> _submit(OfferEditorController controller, JobOfferStatus status) async {
    final result = await controller.submit(status);
    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.isEditing ? 'Offre mise à jour.' : status == JobOfferStatus.draft ? 'Brouillon enregistré.' : 'Offre publiée.'), behavior: SnackBarBehavior.floating));
    context.go(AppRoutes.recruiterJobs);
  }

  static const _labelStyle = TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w800);
}

class _MobileCompanyChoice extends StatelessWidget {
  const _MobileCompanyChoice({required this.company, required this.selected, required this.onTap});
  final RecruiterCompany company;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 90,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.orange : const Color(0xFFE4E8E3), width: selected ? 1.7 : 1)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(clipBehavior: Clip.none, children: [
          CompanyAvatar(company: company, size: 48),
          if (selected) const Positioned(right: -5, top: -5, child: CircleAvatar(radius: 9, backgroundColor: Color(0xFF1976D2), child: Icon(Icons.check_rounded, size: 12, color: Colors.white))),
        ]),
        const SizedBox(height: 8),
        Text(company.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w900)),
      ]),
    ),
  );
}

class _MobileSegments<T> extends StatelessWidget {
  const _MobileSegments({required this.values, required this.selected, required this.labelOf, required this.iconOf, required this.onSelected});
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T) iconOf;
  final ValueChanged<T> onSelected;
  @override
  Widget build(BuildContext context) => Row(children: values.map((value) {
    final active = value == selected;
    return Expanded(child: Padding(
      padding: EdgeInsets.only(right: value == values.last ? 0 : 6),
      child: InkWell(
        onTap: () => onSelected(value),
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 54,
          decoration: BoxDecoration(color: active ? const Color(0xFFEAF4FC) : const Color(0xFFF7F8F6), borderRadius: BorderRadius.circular(13), border: Border.all(color: active ? AppColors.blue : const Color(0xFFE4E8E3))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(iconOf(value), color: active ? const Color(0xFF1976D2) : AppColors.slate, size: 17), const SizedBox(height: 4), Text(labelOf(value), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? const Color(0xFF1976D2) : AppColors.slate, fontSize: 9, fontWeight: FontWeight.w800))]),
        ),
      ),
    ));
  }).toList());
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.values, required this.labelOf, required this.onChanged});
  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: _MobileOfferEditorScreenState._labelStyle),
    const SizedBox(height: 8),
    DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: values.map((item) => DropdownMenuItem(value: item, child: Text(labelOf(item), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (next) { if (next != null) onChanged(next); },
      decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF4F6F3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE4E8E3))), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15)),
    ),
  ]);
}

class _MobileDateField extends StatelessWidget {
  const _MobileDateField({required this.value, required this.onChanged});
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Date de début *', style: _MobileOfferEditorScreenState._labelStyle),
    const SizedBox(height: 8),
    InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(context: context, initialDate: value ?? now, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 8), locale: const Locale('fr', 'FR'));
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 13), decoration: BoxDecoration(color: const Color(0xFFF4F6F3), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4E8E3))), child: Row(children: [const Icon(Icons.calendar_month_outlined, color: Color(0xFF1976D2), size: 18), const SizedBox(width: 8), Expanded(child: Text(monthYearLabel(value), overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w700)))])),
    ),
  ]);
}

String _degreeLabel(String value) => switch (value) { 'BAC_2' => 'Bac+2', 'BAC_3' => 'Bac+3', 'BAC_4' => 'Bac+4', _ => 'Bac+5' };
