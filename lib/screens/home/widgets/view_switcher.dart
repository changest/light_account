import 'package:flutter/material.dart';
import '../../../core/theme/meizu_theme.dart';
import '../../../providers/bill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 视图切换器
/// 日/周/月 切换
class ViewSwitcher extends ConsumerWidget {
  const ViewSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billProvider);
    final notifier = ref.read(billProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MeizuTheme.meizuBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
      ),
      child: Row(
        children: [
          _buildSegment(
            label: '日',
            isSelected: state.viewType == ViewType.day,
            onTap: () => notifier.setViewType(ViewType.day),
          ),
          _buildSegment(
            label: '周',
            isSelected: state.viewType == ViewType.week,
            onTap: () => notifier.setViewType(ViewType.week),
          ),
          _buildSegment(
            label: '月',
            isSelected: state.viewType == ViewType.month,
            onTap: () => notifier.setViewType(ViewType.month),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: MeizuTheme.animationFast,
          curve: MeizuTheme.curveEaseOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(MeizuTheme.radiusSmall),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? MeizuTheme.meizuBlue : MeizuTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
