import 'package:flutter/material.dart';
import '../core/theme/meizu_theme.dart';

/// 魅族风格按钮
class MeizuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const MeizuButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 尺寸配置
    final (height, fontSize, padding) = switch (size) {
      ButtonSize.small => (36.0, 14.0, const EdgeInsets.symmetric(horizontal: 16)),
      ButtonSize.medium => (48.0, 16.0, const EdgeInsets.symmetric(horizontal: 24)),
      ButtonSize.large => (56.0, 18.0, const EdgeInsets.symmetric(horizontal: 32)),
    };

    // 样式配置
    final (backgroundColor, textColor, elevation) = switch (type) {
      ButtonType.primary => (MeizuTheme.meizuBlue, Colors.white, 0.0),
      ButtonType.secondary => (
          isDark ? MeizuTheme.cardDark : MeizuTheme.cardWhite,
          isDark ? MeizuTheme.textPrimaryDark : MeizuTheme.textPrimary,
          0.0
        ),
      ButtonType.ghost => (
          Colors.transparent,
          MeizuTheme.meizuBlue,
          0.0
        ),
      ButtonType.danger => (
          MeizuTheme.expenseRed,
          Colors.white,
          0.0
        ),
    };

    Widget button = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
      elevation: elevation,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
        splashColor: textColor.withOpacity(0.2),
        child: Container(
          height: height,
          padding: padding,
          constraints: fullWidth ? const BoxConstraints(minWidth: double.infinity) : null,
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: fontSize,
                  height: fontSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(textColor),
                  ),
                ),
                SizedBox(width: size == ButtonSize.small ? 6 : 8),
              ] else if (icon != null) ...[
                Icon(icon, size: fontSize, color: textColor),
                SizedBox(width: size == ButtonSize.small ? 6 : 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (type == ButtonType.secondary) {
      button = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: button,
      );
    }

    return button;
  }
}

enum ButtonType { primary, secondary, ghost, danger }
enum ButtonSize { small, medium, large }

/// 魅族风格浮动按钮
class MeizuFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final bool mini;

  const MeizuFloatingButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.label,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = mini ? 48.0 : 56.0;

    Widget button = Material(
      color: MeizuTheme.meizuBlue,
      borderRadius: BorderRadius.circular(MeizuTheme.radiusCircular),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(MeizuTheme.radiusCircular),
        splashColor: Colors.white24,
        child: Container(
          width: label != null ? null : size,
          height: size,
          padding: label != null
              ? const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium)
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: mini ? 20 : 24),
              if (label != null) ...[
                const SizedBox(width: MeizuTheme.spaceSmall),
                Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // 添加阴影
    button = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MeizuTheme.radiusCircular),
        boxShadow: MeizuTheme.buttonShadow,
      ),
      child: button,
    );

    return button;
  }
}

/// 魅族风格图标按钮
class MeizuIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const MeizuIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 40,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: backgroundColor ?? (isDark ? MeizuTheme.cardDark : MeizuTheme.cardWhite),
      borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
        splashColor: MeizuTheme.meizuBlue.withOpacity(0.1),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: color ?? (isDark ? MeizuTheme.textSecondaryDark : MeizuTheme.textSecondary),
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
