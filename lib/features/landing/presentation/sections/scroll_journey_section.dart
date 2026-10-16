// Synchronise une scène de parcours avec le défilement sans remplacer le scroll du navigateur.
//
// Référence : doc/landing/fichiers/scroll_journey_section.md.

import 'package:flutter/material.dart';
import '../../../../design_system/joyn_tokens.dart';
import '../widgets/editorial_layout.dart';
import '../widgets/journey_preview.dart';
import 'journey_carousel.dart';
/// Scène inscrite dans le document et synchronisée au scroll de la page.
class ScrollJourneySection extends StatefulWidget {
  /// Initialise les paramètres de ScrollJourneySection ; les valeurs par défaut figurent dans la signature.
  const ScrollJourneySection({super.key, required this.controller,this.topInset = JoynTokens.navHeight});
  /// Contrôleur fourni ou détenu par le composant pour piloter son défilement.
  final ScrollController controller;
  /// Hauteur de navigation à réserver avant la scène.
  final double topInset;
  /// Crée l’état local associé au widget.
  @override
  State<ScrollJourneySection> createState() => _ScrollJourneySectionState();
}
/// État de ScrollJourneySection ; définit ses données mutables et son rendu.
class _ScrollJourneySectionState extends State<ScrollJourneySection> {
  /// Avancement de la scène ou du tracé, généralement entre zéro et un.
  double progress = 0;
  /// Décalage vertical de la scène à l’intérieur de son espace de document.
  double pin = 0;
  /// Clé permettant de mesurer la position de la scène dans le document.
  final storyKey = GlobalKey();
  /// Contenu des étapes proposées dans cette section.
  static const steps = [
    ('Ton profil', 'Tes compétences prennent du sens avec une réalisation et ton contexte.'),
    ('Les critères', 'Lieu, rythme et compétence : les points communs et les écarts restent visibles.'),
    ('Les deux intérêts', 'Ton intérêt et celui de l’entreprise sont présentés séparément.'),
    ('Le premier échange', 'Un projet à raconter. Des attentes et des questions à partager.'),
  ];
  /// Initialise les abonnements ou programme le travail qui nécessite le premier rendu.
  @override
  void initState() { super.initState(); widget.controller.addListener(update); }
  /// Recalcule la scène après un changement des informations héritées.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }
  /// Actualise les abonnements et les mesures lorsque la configuration du parent change.
  @override
  void didUpdateWidget(covariant ScrollJourneySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.topInset!=widget.topInset) { WidgetsBinding.instance.addPostFrameCallback((_) => update()); }
    if (oldWidget.controller != widget.controller) { oldWidget.controller.removeListener(update); widget.controller.addListener(update); }
  }
  /// Mesure la scène et synchronise sa progression avec le scroll principal.
  void update() {
    if (!mounted) { return; }
    // Boîte de rendu mesurée pour calculer une position ou une taille.
    final box = storyKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) { return; }
    // Hauteur de contenu disponible après retrait de la navigation.
    final viewport = MediaQuery.sizeOf(context).height - widget.topInset;
    // Distance de défilement disponible pour la scène.
    final travel = viewport * 2;
    // Décalage utilisé dans le calcul de position ou la transformation.
    final offset = (widget.topInset - box.localToGlobal(Offset.zero).dy).clamp(0.0, travel).toDouble();
    // Nouvelle progression calculée avant comparaison avec l’état courant.
    final next = offset / travel;
    if ((offset - pin).abs() > .1 || (next - progress).abs() > .001) { setState(() { pin = offset; progress = next; }); }
  }
  /// Change la sélection en respectant les limites du contenu.
  void select(int index, double travel) {
    // Boîte de rendu mesurée pour calculer une position ou une taille.
    final box = storyKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !widget.controller.hasClients) { return; }
    // Position de départ de la scène dans le défilement principal.
    final start = widget.controller.offset + box.localToGlobal(Offset.zero).dy - widget.topInset;
    // Position de défilement demandée, bornée à la zone disponible.
    final destination = (start + travel * index / (steps.length - 1)).clamp(0.0, widget.controller.position.maxScrollExtent).toDouble();
    widget.controller.animateTo(destination, duration: JoynTokens.duration, curve: Curves.easeInOutCubic);
  }
  /// Libère les ressources détenues par cet état avant sa destruction.
  @override
  void dispose() { widget.controller.removeListener(update); super.dispose(); }
  /// Construit la présentation à partir de la configuration et de l’état courant.
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    // Dimensions de la vue lues dans MediaQuery.
    final screen = MediaQuery.sizeOf(context);
    if (constraints.maxWidth < JoynTokens.tablet || screen.height-widget.topInset < JoynTokens.stickySceneHeight-JoynTokens.navHeight || MediaQuery.textScalerOf(context).scale(JoynTokens.body) > JoynTokens.body * 1.1 || MediaQuery.disableAnimationsOf(context)) { return const JourneyCarousel(); }
    // Hauteur de contenu disponible après retrait de la navigation.
    final viewport = screen.height - widget.topInset;
    // Indice de l’étape actuellement affichée.
    final stage = (progress * steps.length).floor().clamp(0, steps.length - 1).toInt();
    return SizedBox(key: storyKey, height: viewport * 3, child: Stack(children: [
      Positioned(top: pin, left: 0, right: 0, height: viewport,
        child: ColoredBox(color: JoynTokens.paper, child: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: JoynTokens.xl, vertical: JoynTokens.md),
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: JoynTokens.content), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionHeading(number: '04 / LE PARCOURS', title: 'Du profil au premier échange.'),
              EditorialSplit(
                leading: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    const Divider(), SizedBox(width: double.infinity, child: TextButton(
                      style: const ButtonStyle(alignment: Alignment.centerLeft), onPressed: () => select(i, viewport * 2),
                      child: Text('${i + 1} / ${steps[i].$1}${stage == i ? ' —' : ''}'),
                    )),
                  ],
                  const SizedBox(height: JoynTokens.md),
                  Semantics(liveRegion: true, child: Text(steps[stage].$2, style: Theme.of(context).textTheme.headlineSmall)),
                  const SizedBox(height: JoynTokens.md), const Text('Défilement libre. Les étapes sont également accessibles par leurs boutons.'),
                ]),
                trailing: AnimatedSwitcher(duration: JoynTokens.menuDuration,
                  child: JourneyPreview(key: ValueKey(stage), stage: stage, compact: true)),
              ),
            ]))),
          ),
        )),
      ),
    ]));
  });
}
