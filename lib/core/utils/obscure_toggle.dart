import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Bascule l'affichage d'un mot de passe sans casser la saisie sur le Web.
///
/// Sur Flutter Web, changer `obscureText` pendant que le champ a le focus
/// désynchronise le formulaire d'autofill du moteur : après être sorti du
/// champ, on ne peut plus rien y écrire. On retire donc le focus avant la
/// bascule, puis on le rend au champ (avec son curseur) une fois le nouvel
/// état affiché.
void toggleObscureText(VoidCallback toggle) {
  final focused = FocusManager.instance.primaryFocus;
  if (!kIsWeb || focused == null) {
    toggle();
    return;
  }

  final editable = focused.context
      ?.findAncestorStateOfType<EditableTextState>();
  final selection = editable?.textEditingValue.selection;

  focused.unfocus();
  toggle();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (focused.context == null) return;
    focused.requestFocus();
    // Le retour du focus sélectionne tout le texte : on remet le curseur
    // là où il était, sinon la prochaine frappe remplacerait le mot de passe.
    if (editable == null || selection == null || !selection.isValid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (editable.mounted) editable.widget.controller.selection = selection;
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  });
}
