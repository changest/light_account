import 'package:flutter/material.dart';

/// 魅族风格设计系统
/// 遵循魅族美学：大面积留白、圆角、克制配色
class MeizuTheme {
  // 主色调
  static const Color meizuBlue = Color(0xFF0085FF);
  static const Color meizuBlueLight = Color(0xFFE6F4FF);

  // 背景色
  static const Color background = Color(0xFFF7F8FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardWhite = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  // 文字色
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // 功能色
  static const Color expenseRed = Color(0xFFFF6B6B);
  static const Color incomeGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFB74D);

  // 圆角规范
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircular = 100.0;

  // 间距规范（8的倍数）
  static const double spaceTiny = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
  static const double spaceXXLarge = 48.0;

  // 阴影规范
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowDark => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: meizuBlue.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // 动画时长
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // 动画曲线
  static const Curve curveEaseOut = Curves.easeOutCubic;
  static const Curve curveEaseIn = Curves.easeInCubic;
  static const Curve curveElastic = Curves.elasticOut;

  // 字体大小
  static const double fontSizeTiny = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeHuge = 32.0;
  static const double fontSizeAmount = 48.0;

  // 禁止实例化
  MeizuTheme._();
}

/// 魅族风格文本样式
class MeizuTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: MeizuTheme.fontSizeAmount,
    fontWeight: FontWeight.w300,
    color: MeizuTheme.textPrimary,
    letterSpacing: -1,
  );

  static const TextStyle headline = TextStyle(
    fontSize: MeizuTheme.fontSizeXXLarge,
    fontWeight: FontWeight.w600,
    color: MeizuTheme.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: MeizuTheme.fontSizeXLarge,
    fontWeight: FontWeight.w500,
    color: MeizuTheme.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: MeizuTheme.fontSizeMedium,
    fontWeight: FontWeight.normal,
    color: MeizuTheme.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: MeizuTheme.fontSizeMedium,
    fontWeight: FontWeight.normal,
    color: MeizuTheme.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: MeizuTheme.fontSizeSmall,
    fontWeight: FontWeight.normal,
    color: MeizuTheme.textTertiary,
  );

  static const TextStyle amount = TextStyle(
    fontSize: MeizuTheme.fontSizeAmount,
    fontWeight: FontWeight.w300,
    letterSpacing: -2,
    color: MeizuTheme.textPrimary,
  );

  static const TextStyle amountSmall = TextStyle(
    fontSize: MeizuTheme.fontSizeXXLarge,
    fontWeight: FontWeight.w400,
    letterSpacing: -1,
    color: MeizuTheme.textPrimary,
  );
}
