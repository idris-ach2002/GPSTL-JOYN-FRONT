import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 32, offset: Offset(0, 12)),
  ];
}
