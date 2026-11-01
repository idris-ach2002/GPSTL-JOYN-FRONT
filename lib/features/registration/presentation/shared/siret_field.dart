import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/theme/joyn_material_theme.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/company_info.dart';
import '../../domain/siret.dart';

/// Champ SIRET ([TextField]) + bouton « Rechercher », puis résultat.
class SiretField extends StatelessWidget {
  const SiretField({
    required this.controller,
    required this.onChanged,
    required this.onSearch,
    required this.isLoading,
    required this.company,
    required this.errorText,
    required this.showHint,
    this.stacked = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearch;
  final bool isLoading;
  final CompanyInfo? company;
  final String? errorText;
  final bool showHint;

  /// Bouton sous le champ plutôt qu'à côté (petits écrans).
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final found = company;

    final field = TextField(
      key: const ValueKey('company-siret'),
      controller: controller,
      onChanged: onChanged,
      onSubmitted: (_) => onSearch(),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.search,
      inputFormatters: const [SiretInputFormatter()],
      style: const TextStyle(letterSpacing: 0.9),
      decoration: InputDecoration(
        labelText: 'Numéro SIRET',
        hintText: '14 chiffres',
        prefixIcon: const Icon(Icons.badge_outlined, size: 20),
        errorText: errorText,
        helperText: showHint
            ? 'Il figure sur votre extrait Kbis ou dans l’Annuaire des entreprises.'
            : null,
      ),
    );

    final button = FilledButton.tonalIcon(
      style: JoynButtonStyles.rounded.merge(
        FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          backgroundColor: AppColors.skyTint,
          foregroundColor: AppColors.navy,
        ),
      ),
      onPressed: isLoading ? null : onSearch,
      icon: isLoading
          ? const ButtonProgress()
          : const Icon(Icons.search_rounded),
      label: Text(isLoading ? 'Recherche…' : 'Rechercher'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stacked) ...[
          field,
          const SizedBox(height: 10),
          button,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field),
              const SizedBox(width: 10),
              button,
            ],
          ),
        if (isLoading) ...[
          const SizedBox(height: 14),
          const LinearProgressIndicator(
            semanticsLabel: 'Recherche de l’entreprise en cours',
          ),
        ],
        if (found != null) ...[
          const SizedBox(height: 14),
          CompanyFoundCard(company: found),
        ],
      ],
    );
  }
}

/// Entreprise retrouvée grâce au SIRET.
class CompanyFoundCard extends StatelessWidget {
  const CompanyFoundCard({required this.company, super.key});

  final CompanyInfo company;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      liveRegion: true,
      child: Card(
        color: AppColors.successTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.successLine),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 23,
            backgroundColor: AppColors.textPrimary,
            child: Text(
              company.initial,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(company.legalName),
          subtitle: Text(
            '${company.city} · ${company.activity} · SIRET vérifié',
            style: textTheme.bodySmall?.copyWith(color: AppColors.slateDark),
          ),
          trailing: Chip(
            avatar: const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.successDeep,
            ),
            label: const Text('Trouvée'),
            labelStyle: textTheme.labelSmall?.copyWith(
              color: AppColors.successDeep,
              letterSpacing: 0,
            ),
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
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
