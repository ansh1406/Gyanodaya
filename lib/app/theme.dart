import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(primary: Colors.indigo),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
