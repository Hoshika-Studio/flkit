import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_theme.tailor.dart';

@TailorMixin()
class AppColors extends ThemeExtension<AppColors> with _$AppColorsTailorMixin {
  const AppColors({
    required this.background,
    required this.foreground,
    required this.muted,
    required this.border,
    required this.card,
    required this.primary,
    required this.primaryForeground,
  });

  @override
  final Color background;
  @override
  final Color foreground;
  @override
  final Color muted;
  @override
  final Color border;
  @override
  final Color card;
  @override
  final Color primary;
  @override
  final Color primaryForeground;

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    muted: Color(0xFF71717A),
    border: Color(0xFFE4E4E7),
    card: Color(0xFFFAFAFA),
    primary: Color(0xFF09090B),
    primaryForeground: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    background: Color(0xFF09090B),
    foreground: Color(0xFFFAFAFA),
    muted: Color(0xFFA1A1AA),
    border: Color(0xFF27272A),
    card: Color(0xFF18181B),
    primary: Color(0xFFFAFAFA),
    primaryForeground: Color(0xFF09090B),
  );
}

class AppTheme {
  static ThemeData get lightTheme => _theme(AppColors.light, Brightness.light);

  static ThemeData get darkTheme => _theme(AppColors.dark, Brightness.dark);

  static ThemeData _theme(AppColors colors, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      primary: colors.primary,
      surface: colors.background,
      onSurface: colors.foreground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: _textTheme.apply(
        bodyColor: colors.foreground,
        displayColor: colors.foreground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.foreground),
        ),
      ),
      extensions: [colors],
    );
  }

  static const _textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );
}

extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
