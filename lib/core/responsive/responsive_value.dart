import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  required T tablet,
  required T desktop,
}) {
  final width = MediaQuery.sizeOf(context).width;

  if (width < AppBreakpoints.mobile) {
    return mobile;
  }

  if (width < AppBreakpoints.tablet) {
    return tablet;
  }

  return desktop;
}
