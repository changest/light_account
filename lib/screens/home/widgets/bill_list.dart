import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme/meizu_theme.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/utils/money_util.dart';
import '../../../models/bill_model.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/category_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 账单列表
class BillList extends ConsumerWidget {
  const BillList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading) {
      return const _LoadingShimmer();
    }

    if (state.bills.isEmpty) {
      return _EmptyState(
        onAddTap: () => _showAddBill(context),
      );
    }

    // 按日期分组
    final groupedBills = _groupBillsByDate(state.bills);

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: MeizuTheme.spaceMedium,
        right: MeizuTheme.spaceMedium,
        bottom: 100, // 为底部按钮留空间
      ),
      itemCount: groupedBills.length,
      itemBuilder: (context, index) {
        final entry = groupedBills.entries.elementAt(index);
        final date = entry.key;
        final bills = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期标题
            _DateHeader(date: date, bills: bills),
            const SizedBox(height: MeizuTheme.spaceSmall),
            // 账单项
            ...bills.map((bill) => _BillItem(
                  bill: bill,
                  onEdit: () => _editBill(context, bill),
                  onDelete: () => _deleteBill(context, ref, bill.id),
                )),
            const SizedBox(height: MeizuTheme.spaceMedium),
          ],
        );
      },
    );
  }

  Map<DateTime, List<Bill>> _groupBillsByDate(List<Bill> bills) {
    final grouped = <DateTime, List<Bill>>{};
    for (final bill in bills) {
      final date = DateUtil.getStartOfDay(bill.date);
      grouped.putIfAbsent(date, () => []).add(bill);
    }
    // 按日期倒序
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  void _showAddBill(BuildContext context) {
    // 导航到添加账单页面
    Navigator.pushNamed(context, '/add');
  }

  void _editBill(BuildContext context, Bill bill) {
    // 导航到编辑账单页面
    Navigator.pushNamed(context, '/add', arguments: bill);
  }

  void _deleteBill(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后可以在回收站中恢复'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(billProvider.notifier).deleteBill(id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: MeizuTheme.expenseRed)),
          ),
        ],
      ),
    );
  }
}

/// 日期分组头部
class _DateHeader extends StatelessWidget {
  final DateTime date;
  final List<Bill> bills;

  const _DateHeader({required this.date, required this.bills});

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtil.isToday(date);
    final totalExpense = bills.where((b) => b.isExpense).fold<int>(0, (sum, b) => sum + b.amount);
    final totalIncome = bills.where((b) => b.isIncome).fold<int>(0, (sum, b) => sum + b.amount);

    return Padding(
      padding: const EdgeInsets.only(top: MeizuTheme.spaceSmall),
      child: Row(
        children: [
          Text(
            isToday ? '今天' : DateUtil.formatDay(date),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MeizuTheme.textPrimary,
            ),
          ),
          const SizedBox(width: MeizuTheme.spaceSmall),
          Text(
            DateUtil.getShortWeekday(date),
            style: const TextStyle(
              fontSize: 12,
              color: MeizuTheme.textTertiary,
            ),
          ),
          const Spacer(),
          if (totalIncome > 0)
            Text(
              '收 ${MoneyUtil.formatMoneySmart(totalIncome, showSymbol: false)}',
              style: const TextStyle(
                fontSize: 12,
                color: MeizuTheme.incomeGreen,
              ),
            ),
          if (totalIncome > 0 && totalExpense > 0)
            const SizedBox(width: MeizuTheme.spaceSmall),
          if (totalExpense > 0)
            Text(
              '支 ${MoneyUtil.formatMoneySmart(totalExpense, showSymbol: false)}',
              style: const TextStyle(
                fontSize: 12,
                color: MeizuTheme.expenseRed,
              ),
            ),
        ],
      ),
    );
  }
}

/// 单个账单项
class _BillItem extends ConsumerWidget {
  final Bill bill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BillItem({
    required this.bill,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryProvider.notifier).getCategoryById(bill.categoryId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: MeizuTheme.spaceTiny),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: MeizuTheme.meizuBlue.withOpacity(0.1),
              foregroundColor: MeizuTheme.meizuBlue,
              borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
              child: const Icon(Icons.edit, size: 20),
            ),
            CustomSlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: MeizuTheme.expenseRed.withOpacity(0.1),
              foregroundColor: MeizuTheme.expenseRed,
              borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
              child: const Icon(Icons.delete, size: 20),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MeizuTheme.spaceMedium,
            vertical: MeizuTheme.spaceSmall,
          ),
          decoration: BoxDecoration(
            color: isDark ? MeizuTheme.cardDark : MeizuTheme.cardWhite,
            borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          ),
          child: Row(
            children: [
              // 分类图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    category?.icon ?? '📦',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: MeizuTheme.spaceMedium),
              // 分类名称和备注
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? '其他',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: MeizuTheme.textPrimary,
                      ),
                    ),
                    if (bill.note != null && bill.note!.isNotEmpty)
                      Text(
                        bill.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MeizuTheme.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 金额
              Text(
                (bill.isExpense ? '-' : '+') + MoneyUtil.formatMoneySmart(bill.amount, showSymbol: false),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: bill.isExpense ? MeizuTheme.expenseRed : MeizuTheme.incomeGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 空状态
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: MeizuTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: MeizuTheme.spaceMedium),
          Text(
            '暂无账单记录',
            style: TextStyle(
              fontSize: 16,
              color: MeizuTheme.textTertiary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: MeizuTheme.spaceSmall),
          TextButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('记一笔'),
          ),
        ],
      ),
    );
  }
}

/// 加载骨架屏
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(MeizuTheme.spaceMedium),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: MeizuTheme.spaceSmall),
          padding: const EdgeInsets.all(MeizuTheme.spaceMedium),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
                ),
              ),
              const SizedBox(width: MeizuTheme.spaceMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
