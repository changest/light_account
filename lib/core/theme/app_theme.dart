import 'package:flutter/material.dart';
import 'meizu_theme.dart';

/// 应用主题配置
class AppTheme {
  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: MeizuTheme.background,
      primaryColor: MeizuTheme.meizuBlue,
      colorScheme: const ColorScheme.light(
        primary: MeizuTheme.meizuBlue,
        secondary: MeizuTheme.meizuBlue,
        surface: MeizuTheme.cardWhite,
        background: MeizuTheme.background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: MeizuTheme.textPrimary,
        onBackground: MeizuTheme.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: MeizuTheme.background,
        foregroundColor: MeizuTheme.textPrimary,
        titleTextStyle: MeizuTextStyles.title,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: MeizuTheme.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeizuTheme.radiusLarge),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MeizuTheme.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MeizuTheme.radiusXLarge),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MeizuTheme.meizuBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeizuTheme.radiusCircular),
        ),
      ),
      iconTheme: const IconThemeData(
        color: MeizuTheme.textSecondary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        space: MeizuTheme.spaceMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MeizuTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          borderSide: const BorderSide(color: MeizuTheme.meizuBlue, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MeizuTheme.spaceMedium,
          vertical: MeizuTheme.spaceSmall,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: MeizuTextStyles.display,
        headlineLarge: MeizuTextStyles.headline,
        titleLarge: MeizuTextStyles.title,
        bodyLarge: MeizuTextStyles.body,
        bodyMedium: MeizuTextStyles.bodySecondary,
        labelMedium: MeizuTextStyles.caption,
      ),
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MeizuTheme.backgroundDark,
      primaryColor: MeizuTheme.meizuBlue,
      colorScheme: const ColorScheme.dark(
        primary: MeizuTheme.meizuBlue,
        secondary: MeizuTheme.meizuBlue,
        surface: MeizuTheme.cardDark,
        background: MeizuTheme.backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: MeizuTheme.textPrimaryDark,
        onBackground: MeizuTheme.textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: MeizuTheme.backgroundDark,
        foregroundColor: MeizuTheme.textPrimaryDark,
        titleTextStyle: TextStyle(
          fontSize: MeizuTheme.fontSizeXLarge,
          fontWeight: FontWeight.w500,
          color: MeizuTheme.textPrimaryDark,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: MeizuTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MeizuTheme.radiusLarge),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MeizuTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MeizuTheme.radiusXLarge),
          ),
        ),
      ),
    );
  }
}
