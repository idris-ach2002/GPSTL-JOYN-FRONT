import 'package:flutter/material.dart';

import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/offer_options.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_editor_controller.dart';
import '../shared/offer_ui.dart';

Future<void> showMobileCompanyPicker(
  BuildContext context,
  OfferEditorController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => FractionallySizedBox(
    heightFactor: .92,
    child: _MobileCompanyPicker(controller: controller),
  ),
);

class _MobileCompanyPicker extends StatefulWidget {
  const _MobileCompanyPicker({required this.controller});
  final OfferEditorController controller;

  @override
  State<_MobileCompanyPicker> createState() => _MobileCompanyPickerState();
}

class _MobileCompanyPickerState extends State<_MobileCompanyPicker> {
  final siret = TextEditingController();
  final name = TextEditingController();
  final website = TextEditingController();
  final city = TextEditingController();
  final manualSiret = TextEditingController();
  final description = TextEditingController();
  String sector = OfferOptions.companySectors.first;
  String size = OfferOptions.companySizes[2];

  @override
  void dispose() {
    for (final item in [siret, name, website, city, manualSiret, description]) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => DecoratedBox(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
        top: false,
        child: Column(children: [
          const SizedBox(height: 10),
          Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(99))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
            child: Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ajouter une entreprise', style: TextStyle(color: AppColors.navy, fontSize: 23, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Recherchez-la dans la base ou créez-la.', style: TextStyle(color: AppColors.slate, fontSize: 12)),
              ])),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 26), children: [
              MobileField(label: 'SIRET', controller: siret, hintText: '732 829 320 00074', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              MobilePrimaryButton(label: 'Rechercher', icon: Icons.search_rounded, loading: widget.controller.companyLookupStatus == CompanyLookupStatus.loading, backgroundColor: AppColors.navy, onPressed: () => widget.controller.lookupCompany(siret.text)),
              if (widget.controller.companyLookupStatus == CompanyLookupStatus.found && widget.controller.companyLookupResult != null) ...[
                const SizedBox(height: 14),
                _FoundCompany(company: widget.controller.companyLookupResult!, onChoose: () {
                  widget.controller.chooseLookupCompany();
                  Navigator.pop(context);
                }),
              ],
              if (widget.controller.companyLookupStatus == CompanyLookupStatus.notFound) ...[
                const SizedBox(height: 12),
                _Info(text: widget.controller.companyLookupError ?? 'Entreprise absente de la base. Créez-la ci-dessous.'),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('ou créer manuellement', style: TextStyle(color: AppColors.placeholder, fontSize: 11))), Expanded(child: Divider())]),
              ),
              const Text('Créer l’entreprise', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              MobileField(label: 'Nom de l’entreprise *', controller: name, hintText: 'Nova Tech'),
              const SizedBox(height: 12),
              MobileField(label: 'Site web', controller: website, hintText: 'https://...'),
              const SizedBox(height: 12),
              _MobileDropdown(label: 'Secteur *', value: sector, values: OfferOptions.companySectors, onChanged: (value) => setState(() => sector = value)),
              const SizedBox(height: 12),
              _MobileDropdown(label: 'Taille *', value: size, values: OfferOptions.companySizes, onChanged: (value) => setState(() => size = value)),
              const SizedBox(height: 12),
              MobileField(label: 'Adresse *', controller: city, hintText: 'Paris, France'),
              const SizedBox(height: 12),
              MobileField(label: 'SIRET', controller: manualSiret, hintText: '14 chiffres', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              MobileField(label: 'Description courte', controller: description, hintText: 'Présentez brièvement l’entreprise…'),
              if (widget.controller.companyLookupError != null) ...[
                const SizedBox(height: 10),
                Text(widget.controller.companyLookupError!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
              const SizedBox(height: 18),
              MobilePrimaryButton(
                label: 'Créer et sélectionner',
                icon: Icons.apartment_rounded,
                backgroundColor: AppColors.orange,
                loading: widget.controller.isCreatingCompany,
                onPressed: () async {
                  final company = await widget.controller.createCompany(RecruiterCompanyDraft(name: name.text, sector: sector, sizeRange: size, city: city.text, siret: manualSiret.text, website: website.text, description: description.text));
                  if (company != null && mounted) Navigator.pop(context);
                },
              ),
            ]),
          ),
        ]),
      ),
    ),
  );
}

class _FoundCompany extends StatelessWidget {
  const _FoundCompany({required this.company, required this.onChoose});
  final RecruiterCompany company;
  final VoidCallback onChoose;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: AppColors.successTint, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.successLine)),
    child: Column(children: [
      Row(children: [CompanyAvatar(company: company, size: 44), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(company.name, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w900)), Text('${company.activity} · ${company.city}', style: const TextStyle(color: AppColors.slate, fontSize: 11))]))]),
      const SizedBox(height: 12),
      MobilePrimaryButton(label: 'Choisir cette entreprise', icon: Icons.check_rounded, backgroundColor: AppColors.successDeep, onPressed: onChoose),
    ]),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.warningTint, borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.info_outline_rounded, color: AppColors.warningDeep, size: 18), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: AppColors.warningDeep, fontSize: 11, fontWeight: FontWeight.w700)))]));
}

class _MobileDropdown extends StatelessWidget {
  const _MobileDropdown({required this.label, required this.value, required this.values, required this.onChanged});
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    DropdownButtonFormField<String>(initialValue: value, isExpanded: true, items: values.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (next) { if (next != null) onChanged(next); }, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF4F6F3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE4E8E3))))),
  ]);
}
