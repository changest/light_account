import 'package:flutter/material.dart';
import '../../../core/theme/meizu_theme.dart';
import '../../../core/utils/date_util.dart';
import '../../../providers/bill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 日期导航头部
/// 显示当前日期和左右切换按钮
class DateHeader extends ConsumerWidget {
  const DateHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billProvider);
    final notifier = ref.read(billProvider.notifier);

    String dateText;
    switch (state.viewType) {
      case ViewType.day:
        if (DateUtil.isToday(state.selectedDate)) {
          dateText = '今天 ${DateUtil.formatDay(state.selectedDate)}';
        } else {
          dateText = DateUtil.formatDay(state.selectedDate);
        }
        break;
      case ViewType.week:
        final start = DateUtil.getStartOfWeek(state.selectedDate);
        final end = DateUtil.getEndOfWeek(state.selectedDate);
        dateText = '${DateUtil.formatDay(start)} - ${DateUtil.formatDay(end)}';
        break;
      case ViewType.month:
        dateText = DateUtil.formatMonth(state.selectedDate);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MeizuTheme.spaceMedium,
        vertical: MeizuTheme.spaceSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 上一周期按钮
          _buildNavButton(
            icon: Icons.chevron_left,
            onTap: notifier.previousPeriod,
          ),

          const SizedBox(width: MeizuTheme.spaceMedium),

          // 日期显示（可点击）
          GestureDetector(
            onTap: () => _showDatePicker(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MeizuTheme.spaceMedium,
                vertical: MeizuTheme.spaceSmall,
              ),
              decoration: BoxDecoration(
                color: MeizuTheme.meizuBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
              ),
              child: Text(
                dateText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: MeizuTheme.meizuBlue,
                ),
              ),
            ),
          ),

          const SizedBox(width: MeizuTheme.spaceMedium),

          // 下一周期按钮
          _buildNavButton(
            icon: Icons.chevron_right,
            onTap: notifier.nextPeriod,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(MeizuTheme.spaceSmall),
          child: Icon(
            icon,
            color: MeizuTheme.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final state = ref.read(billProvider);
    final notifier = ref.read(billProvider.notifier);

    if (state.viewType == ViewType.month) {
      // 显示月份选择器
      final result = await showDialog<DateTime>(
        context: context,
        builder: (context) => _MonthPickerDialog(
          initialDate: state.selectedDate,
        ),
      );
      if (result != null) {
        notifier.setSelectedDate(result);
      }
    } else {
      // 显示日期选择器
      final result = await showDatePicker(
        context: context,
        initialDate: state.selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: MeizuTheme.meizuBlue,
                  ),
            ),
            child: child!,
          );
        },
      );
      if (result != null) {
        notifier.setSelectedDate(result);
      }
    }
  }
}

/// 月份选择对话框
class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _MonthPickerDialog({required this.initialDate});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => selectedYear--),
          ),
          Text(
            '$selectedYear年',
            style: const TextStyle(fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => selectedYear++),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final isSelected = month == selectedMonth;
            return GestureDetector(
              onTap: () {
                Navigator.pop(
                  context,
                  DateTime(selectedYear, month),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? MeizuTheme.meizuBlue : null,
                  borderRadius: BorderRadius.circular(MeizuTheme.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    '$month月',
                    style: TextStyle(
                      color: isSelected ? Colors.white : MeizuTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
