import 'package:flutter/material.dart';
import 'ui/splash.dart';
import 'ui/styles/theme.dart';

void main() {
  runApp(MaterialApp(
    title: "Pedal",
    theme: AppTheme.temaClaro,
    darkTheme: AppTheme.temaEscuro,
    themeMode: ThemeMode.system,
    home: Splash(),
  ));
}