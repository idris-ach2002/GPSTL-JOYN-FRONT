import 'package:flutter/material.dart';

import '../../../../design_system/components/joyn_button.dart';
import '../../../../design_system/components/joyn_text_field.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_fonts.dart';
import '../../../../design_system/tokens/app_shadows.dart';
import '../../domain/offer_options.dart';
import '../../domain/recruiter_company.dart';
import '../controllers/offer_editor_controller.dart';
import '../shared/offer_ui.dart';

Future<void> showCompanyPickerDrawer(
  BuildContext context,
  OfferEditorController controller,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fermer',
    barrierColor: AppColors.navy.withValues(alpha: .58),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, animation, secondaryAnimation) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: FractionallySizedBox(
          widthFactor: MediaQuery.sizeOf(context).width >= 1200 ? .36 : .48,
          heightFactor: 1,
          child: _CompanyPickerDrawer(controller: controller),
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(curved), child: child);
    },
  );
}

class _CompanyPickerDrawer extends StatefulWidget {
  const _CompanyPickerDrawer({required this.controller});
  final OfferEditorController controller;

  @override
  State<_CompanyPickerDrawer> createState() => _CompanyPickerDrawerState();
}

class _CompanyPickerDrawerState extends State<_CompanyPickerDrawer> {
  final _siret = TextEditingController();
  final _name = TextEditingController();
  final _website = TextEditingController();
  final _city = TextEditingController();
  final _manualSiret = TextEditingController();
  final _description = TextEditingController();
  String? _sector = OfferOptions.companySectors.first;
  String? _size = OfferOptions.companySizes[2];

  @override
  void dispose() {
    for (final controller in [_siret, _name, _website, _city, _manualSiret, _description]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Container(
        color: AppColors.background,
        child: SafeArea(
          left: false,
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _searchBlock(),
                      const SizedBox(height: 20),
                      _divider(),
                      const SizedBox(height: 20),
                      _manualBlock(),
                    ],
                  ),
                ),
              ),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 22, 18, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ajouter une entreprise', style: TextStyle(fontFamily: AppFonts.display, color: AppColors.navy, fontSize: 25, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('Recherchez une entreprise existante par son SIRET ou créez-la manuellement si elle n’existe pas encore.', style: TextStyle(color: AppColors.slate, fontSize: 12, height: 1.4)),
          ]),
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
      ],
    ),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.lineSoft), boxShadow: AppShadows.card),
    child: child,
  );

  Widget _searchBlock() => _card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Rechercher par SIRET', style: TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Renseignez le numéro à 14 chiffres pour retrouver une entreprise déjà disponible.', style: TextStyle(color: AppColors.slate, fontSize: 11, height: 1.4)),
      const SizedBox(height: 14),
      JoynTextField(
        label: 'SIRET',
        controller: _siret,
        hintText: '732 829 320 00074',
        prefixIcon: Icons.apartment_rounded,
        keyboardType: TextInputType.number,
        trailingAction: SizedBox(
          height: 50,
          child: JoynButton(
            label: 'Rechercher',
            variant: JoynButtonVariant.accent,
            fontSize: 13,
            height: 50,
            isLoading: widget.controller.companyLookupStatus == CompanyLookupStatus.loading,
            onPressed: () => widget.controller.lookupCompany(_siret.text),
          ),
        ),
      ),
      if (widget.controller.companyLookupStatus == CompanyLookupStatus.found && widget.controller.companyLookupResult != null) ...[
        const SizedBox(height: 14),
        _foundCompany(widget.controller.companyLookupResult!),
      ] else if (widget.controller.companyLookupStatus == CompanyLookupStatus.notFound) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.warningTint, borderRadius: BorderRadius.circular(13)),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warningDeep),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.controller.companyLookupError ?? 'Aucune entreprise trouvée : vous pouvez la créer ci-dessous.', style: const TextStyle(color: AppColors.warningDeep, fontSize: 11, fontWeight: FontWeight.w600))),
          ]),
        ),
      ],
    ]),
  );

  Widget _foundCompany(RecruiterCompany company) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.successTint, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.successLine)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.check_circle_rounded, color: AppColors.successDeep, size: 17), SizedBox(width: 7), Text('Entreprise trouvée', style: TextStyle(color: AppColors.successDeep, fontWeight: FontWeight.w800, fontSize: 12))]),
      const SizedBox(height: 13),
      Row(children: [
        CompanyAvatar(company: company, size: 48),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(company.name, style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900)),
          Text('${company.activity} · ${company.sizeRange} salariés', style: const TextStyle(color: AppColors.slate, fontSize: 11)),
          Text(company.city, style: const TextStyle(color: AppColors.slate, fontSize: 11)),
        ])),
      ]),
      if (company.description.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(company.description, style: const TextStyle(color: AppColors.slate, fontSize: 11, height: 1.4)),
      ],
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerRight,
        child: JoynButton(
          label: 'Choisir cette entreprise',
          variant: JoynButtonVariant.accent,
          height: 42,
          fontSize: 12,
          onPressed: () {
            widget.controller.chooseLookupCompany();
            Navigator.pop(context);
          },
        ),
      ),
    ]),
  );

  Widget _divider() => Row(children: [
    const Expanded(child: Divider(color: AppColors.lineSoft)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('ou créer manuellement', style: TextStyle(color: AppColors.slate.withValues(alpha: .9), fontSize: 11, fontWeight: FontWeight.w600))),
    const Expanded(child: Divider(color: AppColors.lineSoft)),
  ]);

  Widget _manualBlock() => _card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Créer une entreprise manuellement', style: TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Une fois créée, elle sera disponible dans la base et sélectionnée pour cette offre.', style: TextStyle(color: AppColors.slate, fontSize: 11, height: 1.4)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: JoynTextField(label: 'Nom de l’entreprise *', controller: _name, hintText: 'Ex. Nova Tech', prefixIcon: Icons.apartment_rounded)),
        const SizedBox(width: 12),
        Expanded(child: JoynTextField(label: 'Site web', controller: _website, hintText: 'https://...', prefixIcon: Icons.link_rounded)),
      ]),
      const SizedBox(height: 13),
      Row(children: [
        Expanded(child: _select(label: 'Secteur d’activité *', value: _sector!, values: OfferOptions.companySectors, onChanged: (value) => setState(() => _sector = value))),
        const SizedBox(width: 12),
        Expanded(child: _select(label: 'Taille de l’entreprise *', value: _size!, values: OfferOptions.companySizes, onChanged: (value) => setState(() => _size = value))),
      ]),
      const SizedBox(height: 13),
      JoynTextField(label: 'Adresse *', controller: _city, hintText: 'Ex. 12 rue de la Paix, Paris', prefixIcon: Icons.location_on_outlined),
      const SizedBox(height: 13),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: JoynTextField(label: 'SIRET', labelSuffix: '(optionnel)', controller: _manualSiret, hintText: '14 chiffres', prefixIcon: Icons.numbers_rounded)),
        const SizedBox(width: 12),
        Expanded(child: JoynTextField(label: 'Description courte *', controller: _description, hintText: 'Présentez brièvement l’entreprise...', prefixIcon: Icons.description_outlined)),
      ]),
      const SizedBox(height: 13),
      Container(
        height: 88,
        decoration: BoxDecoration(color: const Color(0xFFF8FBFD), borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.blue, style: BorderStyle.solid)),
        child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.upload_rounded, color: AppColors.blue),
          SizedBox(height: 4),
          Text('Logo de l’entreprise', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 11)),
          Text('PNG, JPG ou SVG · préparation UI', style: TextStyle(color: AppColors.slate, fontSize: 9)),
        ])),
      ),
      if (widget.controller.companyLookupError != null) ...[
        const SizedBox(height: 10),
        Text(widget.controller.companyLookupError!, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ]),
  );

  Widget _select({required String label, required String value, required List<String> values, required ValueChanged<String> onChanged}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 7),
      DropdownButtonFormField<String>(
        initialValue: value,
        items: values.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (next) { if (next != null) onChanged(next); },
        decoration: InputDecoration(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line))),
      ),
    ],
  );

  Widget _footer(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
    decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.lineSoft))),
    child: Row(children: [
      Expanded(child: JoynButton(label: 'Annuler', variant: JoynButtonVariant.outline, height: 48, onPressed: () => Navigator.pop(context))),
      const SizedBox(width: 12),
      Expanded(child: JoynButton(
        label: 'Créer l’entreprise',
        variant: JoynButtonVariant.accent,
        height: 48,
        isLoading: widget.controller.isCreatingCompany,
        onPressed: () async {
          final company = await widget.controller.createCompany(RecruiterCompanyDraft(name: _name.text, sector: _sector ?? '', sizeRange: _size ?? '', city: _city.text, siret: _manualSiret.text, website: _website.text, description: _description.text));
          if (company == null || !context.mounted) return;
          Navigator.pop(context);
        },
      )),
    ]),
  );
}
