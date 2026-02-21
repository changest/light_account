import 'package:flutter/material.dart';
import '../../../core/theme/meizu_theme.dart';
import '../../../core/utils/money_util.dart';
import '../../../providers/bill_provider.dart';
import '../../../widgets/animated_counter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 金额展示卡片
/// 显示支出、收入、结余
class AmountCard extends ConsumerWidget {
  const AmountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium),
      padding: const EdgeInsets.all(MeizuTheme.spaceLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MeizuTheme.meizuBlue,
            Color(0xFF00A8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(MeizuTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: MeizuTheme.meizuBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 结余
          _buildAmountSection(
            label: '结余',
            amount: state.balance,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: MeizuTheme.spaceLarge),
          // 支出和收入
          Row(
            children: [
              Expanded(
                child: _buildAmountSection(
                  label: '支出',
                  amount: -state.totalExpense,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  icon: Icons.arrow_downward,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildAmountSection(
                  label: '收入',
                  amount: state.totalIncome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  icon: Icons.arrow_upward,
                  alignRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection({
    required String label,
    required int amount,
    required TextStyle style,
    IconData? icon,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && !alignRight) ...[
              Icon(icon, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            if (icon != null && alignRight) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: Colors.white54),
            ],
          ],
        ),
        const SizedBox(height: MeizuTheme.spaceTiny),
        AnimatedCounter(
          value: amount.abs(),
          style: style,
          showSymbol: true,
        ),
      ],
    );
  }
}

/// 简洁金额卡片（用于列表上方）
class CompactAmountCard extends ConsumerWidget {
  const CompactAmountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium),
      padding: const EdgeInsets.all(MeizuTheme.spaceMedium),
      decoration: BoxDecoration(
        color: isDark ? MeizuTheme.cardDark : MeizuTheme.cardWhite,
        borderRadius: BorderRadius.circular(MeizuTheme.radiusLarge),
        boxShadow: isDark ? MeizuTheme.cardShadowDark : MeizuTheme.cardShadow,
      ),
      child: Row(
        children: [
          // 支出
          Expanded(
            child: _buildCompactItem(
              label: '支出',
              amount: state.totalExpense,
              color: MeizuTheme.expenseRed,
              icon: Icons.remove_circle,
            ),
          ),
          // 分隔线
          Container(
            width: 1,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium),
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          // 收入
          Expanded(
            child: _buildCompactItem(
              label: '收入',
              amount: state.totalIncome,
              color: MeizuTheme.incomeGreen,
              icon: Icons.add_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactItem({
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MeizuTheme.radiusSmall),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: MeizuTheme.spaceSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: MeizuTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                MoneyUtil.formatMoneySmart(amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
