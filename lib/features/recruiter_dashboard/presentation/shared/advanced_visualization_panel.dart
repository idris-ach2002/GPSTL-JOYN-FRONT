import 'package:flutter/material.dart';

import '../../domain/recruiter_dashboard_models.dart';
import 'dashboard_components.dart';
import 'visualization_settings.dart';

enum _SettingsLevel { basic, advanced, expert }

class AdvancedVisualizationPanel extends StatefulWidget {
  const AdvancedVisualizationPanel({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.dataMax,
    this.compact = false,
  });

  final VisualizationSettings settings;
  final ValueChanged<VisualizationSettings> onChanged;
  final double dataMax;
  final bool compact;

  @override
  State<AdvancedVisualizationPanel> createState() =>
      _AdvancedVisualizationPanelState();
}

class _AdvancedVisualizationPanelState
    extends State<AdvancedVisualizationPanel> {
  _SettingsLevel _level = _SettingsLevel.basic;
  int _page = 0;

  VisualizationSettings get settings => widget.settings;

  int get _pageCount => switch (_level) {
    _SettingsLevel.basic => 2,
    _SettingsLevel.advanced => 3,
    _SettingsLevel.expert => 2,
  };

  void _emit(VisualizationSettings value) => widget.onChanged(value);

  void _changeLevel(_SettingsLevel value) {
    setState(() {
      _level = value;
      _page = 0;
    });
  }

  void _previousPage() {
    if (_page == 0) return;
    setState(() => _page--);
  }

  void _nextPage() {
    if (_page >= _pageCount - 1) return;
    setState(() => _page++);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: DashboardSectionTitle(
                title: 'Paramètres de visualisation',
              ),
            ),
            IconButton(
              tooltip: 'Réinitialiser',
              onPressed: () => _emit(VisualizationSettings.standard),
              icon: const Icon(Icons.restart_alt_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<_SettingsLevel>(
            segments: const [
              ButtonSegment(
                value: _SettingsLevel.basic,
                label: Text('Basique'),
              ),
              ButtonSegment(
                value: _SettingsLevel.advanced,
                label: Text('Avancé'),
              ),
              ButtonSegment(
                value: _SettingsLevel.expert,
                label: Text('Expert'),
              ),
            ],
            selected: {_level},
            showSelectedIcon: false,
            onSelectionChanged: (value) => _changeLevel(value.first),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: ConstrainedBox(
            key: ValueKey('${_level.name}-$_page'),
            constraints: BoxConstraints(minHeight: widget.compact ? 210 : 235),
            child: _pageContent(),
          ),
        ),
        const SizedBox(height: 12),
        _PageNavigator(
          page: _page,
          pageCount: _pageCount,
          onPrevious: _page == 0 ? null : _previousPage,
          onNext: _page >= _pageCount - 1 ? null : _nextPage,
        ),
      ],
    );
  }

  Widget _pageContent() => switch ((_level, _page)) {
    (_SettingsLevel.basic, 0) => _basicTypePage(),
    (_SettingsLevel.basic, _) => _basicSeriesPage(),
    (_SettingsLevel.advanced, 0) => _advancedCurvePage(),
    (_SettingsLevel.advanced, 1) => _advancedDisplayPage(),
    (_SettingsLevel.advanced, _) => _advancedThemePage(),
    (_SettingsLevel.expert, 0) => _expertThresholdPage(),
    (_SettingsLevel.expert, _) => _expertSafetyPage(),
  };

  Widget _basicTypePage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeading(
        'Schéma & comparaison',
        'Choisissez le rendu principal et la référence de comparaison.',
      ),
      const SizedBox(height: 14),
      _label('Type de schéma'),
      const SizedBox(height: 6),
      DropdownButtonFormField<AnalyticsVisualType>(
        initialValue: settings.visualType,
        decoration: _inputDecoration(),
        items: const [
          DropdownMenuItem(
            value: AnalyticsVisualType.lines,
            child: Text('Courbes'),
          ),
          DropdownMenuItem(
            value: AnalyticsVisualType.area,
            child: Text('Aires'),
          ),
          DropdownMenuItem(
            value: AnalyticsVisualType.bars,
            child: Text('Barres'),
          ),
          DropdownMenuItem(
            value: AnalyticsVisualType.scatter,
            child: Text('Nuage de points'),
          ),
        ],
        onChanged: (value) {
          if (value != null) _emit(settings.copyWith(visualType: value));
        },
      ),
      const SizedBox(height: 10),
      _switch(
        'Comparer à N-1',
        settings.showPrevious,
        (value) => _emit(settings.copyWith(showPrevious: value)),
      ),
    ],
  );

  Widget _basicSeriesPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeading(
        'Séries affichées',
        'Activez les indicateurs et ajustez leur couleur.',
      ),
      const SizedBox(height: 8),
      for (final kind in const [
        DashboardSeriesKind.applications,
        DashboardSeriesKind.matches,
        DashboardSeriesKind.interviews,
      ])
        _SeriesToggle(
          kind: kind,
          selected: settings.visibleSeries.contains(kind),
          color: settings.colorFor(kind),
          onColorTap: () => _pickSeriesColor(kind),
          onChanged: (enabled) {
            final next = {...settings.visibleSeries};
            if (enabled) {
              next.add(kind);
            } else if (next.length > 1) {
              next.remove(kind);
            }
            _emit(settings.copyWith(visibleSeries: next));
          },
        ),
    ],
  );

  Widget _advancedCurvePage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeading(
        'Forme de la courbe',
        'Interpolation et géométrie du tracé.',
      ),
      const SizedBox(height: 12),
      _label('Interpolation'),
      const SizedBox(height: 6),
      SegmentedButton<ChartInterpolation>(
        segments: const [
          ButtonSegment(
            value: ChartInterpolation.linear,
            label: Text('Linéaire'),
          ),
          ButtonSegment(
            value: ChartInterpolation.smooth,
            label: Text('Spline'),
          ),
          ButtonSegment(value: ChartInterpolation.step, label: Text('Step')),
        ],
        selected: {settings.interpolation},
        showSelectedIcon: false,
        onSelectionChanged: (value) =>
            _emit(settings.copyWith(interpolation: value.first)),
      ),
      const SizedBox(height: 12),
      _BoundedSlider(
        label: 'Épaisseur',
        value: settings.safeLineWidth,
        min: 1,
        max: 6,
        divisions: 20,
        suffix: 'px',
        onChanged: (value) => _emit(settings.copyWith(lineWidth: value)),
      ),
      _BoundedSlider(
        label: 'Lissage',
        value: settings.safeSmoothing,
        min: 0,
        max: 1,
        divisions: 20,
        valueBuilder: (value) => '${(value * 100).round()}%',
        onChanged: (value) => _emit(settings.copyWith(smoothing: value)),
      ),
    ],
  );

  Widget _advancedDisplayPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeading(
        'Lecture & inspection',
        'Réduisez le bruit visuel ou affichez plus de détails.',
      ),
      const SizedBox(height: 8),
      _BoundedSlider(
        label: 'Opacité aire',
        value: settings.safeAreaOpacity,
        min: 0,
        max: .6,
        divisions: 12,
        valueBuilder: (value) => '${(value * 100).round()}%',
        onChanged: (value) => _emit(settings.copyWith(areaOpacity: value)),
      ),
      _switch(
        'Points de mesure',
        settings.showDots,
        (value) => _emit(settings.copyWith(showDots: value)),
      ),
      _switch(
        'Grille',
        settings.showGrid,
        (value) => _emit(settings.copyWith(showGrid: value)),
      ),
      _switch(
        'Crosshair / inspection',
        settings.showCrosshair,
        (value) => _emit(settings.copyWith(showCrosshair: value)),
      ),
    ],
  );

  Widget _advancedThemePage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeading(
        'Style & typographie',
        'Palette contrôlée et polices embarquées dans JOYN.',
      ),
      const SizedBox(height: 10),
      _label('Palette'),
      const SizedBox(height: 6),
      DropdownButtonFormField<VisualizationPalette>(
        initialValue: settings.palette,
        decoration: _inputDecoration(),
        items: const [
          DropdownMenuItem(
            value: VisualizationPalette.joyn,
            child: Text('JOYN'),
          ),
          DropdownMenuItem(
            value: VisualizationPalette.scientific,
            child: Text('Scientifique'),
          ),
          DropdownMenuItem(
            value: VisualizationPalette.monochrome,
            child: Text('Monochrome'),
          ),
          DropdownMenuItem(
            value: VisualizationPalette.contrast,
            child: Text('Contraste'),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          _emit(
            settings.copyWith(palette: value, customSeriesColors: const {}),
          );
        },
      ),
      const SizedBox(height: 10),
      _label('Police'),
      const SizedBox(height: 6),
      DropdownButtonFormField<VisualizationFont>(
        initialValue: settings.font,
        decoration: _inputDecoration(),
        items: const [
          DropdownMenuItem(
            value: VisualizationFont.instrumentSans,
            child: Text('Instrument Sans'),
          ),
          DropdownMenuItem(
            value: VisualizationFont.roboto,
            child: Text('Roboto'),
          ),
          DropdownMenuItem(
            value: VisualizationFont.bricolage,
            child: Text('Bricolage Grotesque'),
          ),
          DropdownMenuItem(
            value: VisualizationFont.monospace,
            child: Text('Monospace analytique'),
          ),
        ],
        onChanged: (value) {
          if (value != null) _emit(settings.copyWith(font: value));
        },
      ),
      const SizedBox(height: 8),
      _BoundedSlider(
        label: 'Taille texte',
        value: settings.safeFontSize,
        min: 10,
        max: 18,
        divisions: 8,
        suffix: 'px',
        onChanged: (value) => _emit(settings.copyWith(fontSize: value)),
      ),
    ],
  );

  Widget _expertThresholdPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeading(
        'Seuil de supervision',
        'Ajoutez une limite horizontale sans sortir du domaine des données.',
      ),
      const SizedBox(height: 8),
      _switch('Afficher un seuil', settings.threshold != null, (enabled) {
        _emit(
          enabled
              ? settings.copyWith(
                  threshold: widget.dataMax <= 0 ? 0 : widget.dataMax * .7,
                )
              : settings.copyWith(clearThreshold: true),
        );
      }),
      if (settings.threshold != null && widget.dataMax > 0) ...[
        const SizedBox(height: 6),
        _BoundedSlider(
          label: 'Valeur du seuil',
          value: settings.safeThreshold(widget.dataMax) ?? 0,
          min: 0,
          max: widget.dataMax,
          divisions: 20,
          onChanged: (value) => _emit(settings.copyWith(threshold: value)),
        ),
      ],
    ],
  );

  Widget _expertSafetyPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _pageHeading(
        'Garde-fous du moteur',
        'Les valeurs extrêmes sont automatiquement ramenées dans une zone sûre.',
      ),
      const SizedBox(height: 12),
      const _SafetyRow(label: 'Épaisseur du tracé', value: '1 → 6 px'),
      const _SafetyRow(label: 'Opacité des aires', value: '0 → 60 %'),
      const _SafetyRow(label: 'Taille du texte', value: '10 → 18 px'),
      const _SafetyRow(label: 'Lissage', value: '0 → 100 %'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: dashboardBorder),
        ),
        child: const Text(
          'Le rendu 3D a été retiré : le dashboard conserve uniquement les visualisations 2D utiles et la concentration jour/heure.',
          style: TextStyle(color: dashboardMuted, fontSize: 9.5, height: 1.35),
        ),
      ),
    ],
  );

  Widget _pageHeading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: dashboardNavy,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: const TextStyle(
          color: dashboardMuted,
          fontSize: 9.5,
          height: 1.3,
        ),
      ),
    ],
  );

  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(
          color: dashboardNavy,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: dashboardMuted,
      fontSize: 10,
      fontWeight: FontWeight.w800,
    ),
  );

  InputDecoration _inputDecoration() => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: dashboardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: dashboardBlue),
    ),
  );

  Future<void> _pickSeriesColor(DashboardSeriesKind kind) async {
    const colors = [
      Color(0xFF123E72),
      Color(0xFF2676E8),
      Color(0xFF4A91E8),
      Color(0xFF005F73),
      Color(0xFF0A9396),
      Color(0xFF198754),
      Color(0xFFFF7043),
      Color(0xFFEE9B00),
      Color(0xFF9B5DE5),
      Color(0xFF6B7280),
      Color(0xFF111827),
      Color(0xFFA8B8C7),
    ];
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Couleur · ${kind.label}'),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in colors)
                InkWell(
                  onTap: () => Navigator.of(context).pop(color),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Color(0x22000000), blurRadius: 5),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) _emit(settings.withSeriesColor(kind, picked));
  }
}

class _PageNavigator extends StatelessWidget {
  const _PageNavigator({
    required this.page,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton.outlined(
        tooltip: 'Page précédente',
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left_rounded, size: 18),
      ),
      Expanded(
        child: Text(
          '${page + 1} / $pageCount',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: dashboardMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      FilledButton.icon(
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right_rounded, size: 18),
        label: Text(onNext == null ? 'Fin' : 'Suivant'),
      ),
    ],
  );
}

class _SafetyRow extends StatelessWidget {
  const _SafetyRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(Icons.shield_outlined, size: 15, color: dashboardBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: dashboardNavy, fontSize: 10.5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: dashboardMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _SeriesToggle extends StatelessWidget {
  const _SeriesToggle({
    required this.kind,
    required this.selected,
    required this.color,
    required this.onChanged,
    required this.onColorTap,
  });

  final DashboardSeriesKind kind;
  final bool selected;
  final Color color;
  final ValueChanged<bool> onChanged;
  final VoidCallback onColorTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Checkbox(
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
      ),
      Expanded(
        child: Text(
          kind.label,
          style: const TextStyle(color: dashboardNavy, fontSize: 11),
        ),
      ),
      Tooltip(
        message: 'Modifier la couleur',
        child: InkWell(
          onTap: onColorTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: dashboardBorder),
            ),
          ),
        ),
      ),
    ],
  );
}

class _BoundedSlider extends StatelessWidget {
  const _BoundedSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.suffix = '',
    this.valueBuilder,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String suffix;
  final String Function(double)? valueBuilder;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(min, max).toDouble();
    final display =
        valueBuilder?.call(safeValue) ??
        '${safeValue.toStringAsFixed(safeValue % 1 == 0 ? 0 : 1)}$suffix';
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: dashboardNavy,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                display,
                style: const TextStyle(
                  color: dashboardMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: safeValue,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
