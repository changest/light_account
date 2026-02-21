import 'package:flutter/material.dart';
import '../core/theme/meizu_theme.dart';

/// 魅族风格卡片组件
/// 统一圆角、阴影、留白规范
class MeizuCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool enableInkWell;

  const MeizuCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(MeizuTheme.spaceMedium),
    this.margin = const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium, vertical: MeizuTheme.spaceSmall),
    this.backgroundColor,
    this.borderRadius = MeizuTheme.radiusLarge,
    this.boxShadow,
    this.onTap,
    this.enableInkWell = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? MeizuTheme.cardDark : MeizuTheme.cardWhite),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? (isDark ? MeizuTheme.cardShadowDark : MeizuTheme.cardShadow),
      ),
      child: child,
    );

    if (onTap != null) {
      if (enableInkWell) {
        card = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: MeizuTheme.meizuBlue.withOpacity(0.1),
            highlightColor: MeizuTheme.meizuBlue.withOpacity(0.05),
            child: card,
          ),
        );
      } else {
        card = GestureDetector(
          onTap: onTap,
          child: card,
        );
      }
    }

    return card;
  }
}

/// 魅族风格列表项卡片
class MeizuListItem extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const MeizuListItem({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: MeizuTheme.spaceMedium,
      vertical: MeizuTheme.spaceSmall,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return MeizuCard(
      padding: padding,
      margin: const EdgeInsets.symmetric(
        horizontal: MeizuTheme.spaceMedium,
        vertical: MeizuTheme.spaceTiny,
      ),
      onTap: onTap,
      child: Row(
        children: [
          leading,
          const SizedBox(width: MeizuTheme.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: MeizuTheme.spaceTiny),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 魅族风格统计卡片
class MeizuStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;
  final IconData? icon;

  const MeizuStatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MeizuCard(
      padding: const EdgeInsets.all(MeizuTheme.spaceLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: MeizuTheme.textTertiary,
                ),
                const SizedBox(width: MeizuTheme.spaceSmall),
              ],
              Text(
                label,
                style: MeizuTextStyles.caption.copyWith(
                  color: isDark ? MeizuTheme.textSecondaryDark : MeizuTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: MeizuTheme.spaceSmall),
          Text(
            value,
            style: MeizuTextStyles.amountSmall.copyWith(
              color: valueColor ?? (isDark ? MeizuTheme.textPrimaryDark : MeizuTheme.textPrimary),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: MeizuTheme.spaceTiny),
            Text(
              subtitle!,
              style: MeizuTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}
