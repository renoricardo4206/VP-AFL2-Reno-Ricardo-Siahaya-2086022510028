import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Colors.indigo;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: Brightness.light,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: Brightness.dark,
  );
}