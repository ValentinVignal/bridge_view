import 'package:material_ui/material_ui.dart';

ThemeData getTheme(Brightness brightness) => switch (brightness) {
  Brightness.light => _lightTheme,
  Brightness.dark => _darkTheme,
};

// crates.io color palette
const _cratesGold = Color(0xFFFFC832); // Yellow/gold buttons & search icon
const _cratesGreen = Color(0xFF3D9E4F); // Links, tags, active tabs
const _cratesOlive = Color(0xFF5B6F2E); // Light theme header/nav
const _cratesCream = Color(0xFFF9F7EC); // Light theme content background
const _cratesDarkBg = Color(0xFF252525); // Dark theme background
const _cratesDarkCard = Color(0xFF383838); // Dark theme cards/surfaces
const _cratesCharcoal = Color(0xFF2A2A2A); // Light theme body text
const _cratesRed = Color(0xFFD94040); // Error

final _lightTheme = ThemeData.from(
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: _cratesOlive,
    onPrimary: Colors.white,
    secondary: _cratesGold,
    onSecondary: _cratesCharcoal,
    tertiary: _cratesGreen,
    onTertiary: Colors.white,
    error: _cratesRed,
    onError: Colors.white,
    surface: _cratesCream,
    onSurface: _cratesCharcoal,
    surfaceContainerHighest: Colors.white,
  ),
);

final _darkTheme = ThemeData.from(
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: _cratesGold,
    onPrimary: _cratesCharcoal,
    secondary: _cratesGreen,
    onSecondary: Colors.white,
    tertiary: _cratesGreen,
    onTertiary: Colors.white,
    error: _cratesRed,
    onError: Colors.white,
    surface: _cratesDarkBg,
    onSurface: const Color(0xFFE8E6D9),
    surfaceContainerHighest: _cratesDarkCard,
  ),
);
