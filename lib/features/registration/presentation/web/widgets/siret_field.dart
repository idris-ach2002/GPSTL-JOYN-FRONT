import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:joyn_front/design_system/components/joyn_button.dart';
import 'package:joyn_front/design_system/components/joyn_field_message.dart';
import 'package:joyn_front/design_system/components/joyn_text_field.dart';
import 'package:joyn_front/design_system/tokens/app_colors.dart';
import 'package:joyn_front/design_system/tokens/app_fonts.dart';
import 'package:joyn_front/features/registration/domain/company_info.dart';
import 'package:joyn_front/features/registration/domain/siret.dart';

/// Champ SIRET + bouton « Rechercher », puis résultat de la recherche.
class SiretField extends StatelessWidget {
  const SiretField({
    required this.controller,
    required this.onChanged,
    required this.onSearch,
    required this.isLoading,
    required this.company,
    required this.errorText,
    required this.showHint,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  final bool isLoading;
  final CompanyInfo? company;
  final String? errorText;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final found = company;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JoynTextField(
          key: const ValueKey('company-siret'),
          label: 'Numéro SIRET',
          controller: controller,
          onChanged: onChanged,
          onSubmitted: (_) => onSearch(),
          hintText: '14 chiffres',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          letterSpacing: 0.9,
          inputFormatters: const [SiretInputFormatter()],
          errorText: errorText,
          helper: showHint
              ? const JoynFieldMessage(
                  'Il figure sur votre extrait Kbis ou dans l’Annuaire des entreprises.',
                )
              : null,
          trailingAction: JoynButton(
            label: isLoading ? 'Recherche…' : 'Rechercher',
            leadingIcon: isLoading ? null : Icons.search_rounded,
            height: 50,
            fontSize: 14,
            borderRadius: 14,
            isLoading: isLoading,
            onPressed: onSearch,
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 14),
          Semantics(
            label: 'Recherche de l’entreprise en cours',
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.track,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
        if (found != null) ...[
          const SizedBox(height: 14),
          _CompanyFoundCard(company: found),
        ],
      ],
    );
  }
}

class _CompanyFoundCard extends StatelessWidget {
  const _CompanyFoundCard({required this.company});

  final CompanyInfo company;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Entreprise trouvée : ${company.legalName}, ${company.city}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.successTint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.successLine),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                company.initial,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.legalName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${company.city} · ${company.activity} · SIRET vérifié',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slateDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.successDeep,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Trouvée',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successDeep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ne garde que les chiffres (14 max) et les groupe : « 123 456 789 00012 ».
class SiretInputFormatter extends TextInputFormatter {
  const SiretInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = Siret.format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
