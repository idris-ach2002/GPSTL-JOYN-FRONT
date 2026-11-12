import 'package:flutter/widgets.dart';
import 'package:joyn_front/design_system/components/joyn_logo.dart';

class JoynMark extends StatelessWidget {
  const JoynMark({this.size = 44, super.key});
  final double size;

  @override
  Widget build(BuildContext context) => JoynLogo(markSize: size);
}
