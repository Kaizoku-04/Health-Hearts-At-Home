import 'package:flutter/material.dart';

final Color base = const Color.fromARGB(255, 31, 95, 199);

Map<int, Color> _customShades = {
  50: base.withValues(alpha: .1),
  100: base.withValues(alpha: .2),
  200: base.withValues(alpha: .3),
  300: base.withValues(alpha: .4),
  400: base.withValues(alpha: .5),
  500: base.withValues(alpha: .6),
  600: base.withValues(alpha: .7),
  700: base.withValues(alpha: .8),
  800: base.withValues(alpha: .9),
  900: base,
};

MaterialColor customTheme = MaterialColor(base.toARGB32(), _customShades);
