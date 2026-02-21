import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/meizu_theme.dart';
import '../../core/utils/money_util.dart';
import '../../data/database/bill_dao.dart';
import '../../models/bill_model.dart';
import '../../providers/bill_provider.dart';
import '../../providers/category_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 记账页面
/// 半屏弹窗样式，包含金额输入和分类选择
class AddBillScreen extends ConsumerStatefulWidget {
  final Bill? editBill;

  const AddBillScreen({super.key, this.editBill});

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  late BillType _selectedType;
  String _amountInput = '';
  String? _selectedCategoryId;
  String _note = '';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.editBill?.type ?? BillType.expense;
    _selectedCategoryId = widget.editBill?.categoryId;
    _selectedDate = widget.editBill?.date ?? DateTime.now();
    _noteController.text = widget.editBill?.note ?? '';

    if (widget.editBill != null) {
      // 将分转换为输入字符串（如 3500分 -> "3500"）
      _amountInput = widget.editBill!.amount.toString();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MeizuTheme.backgroundDark : MeizuTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航
            _buildHeader(),
            // 金额显示
            _buildAmountDisplay(),
            // 类型切换和日期选择
            _buildTypeAndDate(),
            // 分类选择
            _buildCategoryGrid(),
            // 备注输入
            if (_note.isNotEmpty || _noteController.text.isNotEmpty)
              _buildNoteInput(),
            // 数字键盘
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(MeizuTheme.spaceMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 16,
                color: MeizuTheme.textSecondary,
              ),
            ),
          ),
          Text(
            widget.editBill != null ? '编辑账单' : '记一笔',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: _saveBill,
            child: const Text(
              '保存',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MeizuTheme.meizuBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    final displayAmount = MoneyUtil.formatInputAmount(_amountInput);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: MeizuTheme.spaceLarge),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: MeizuTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                displayAmount,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -2,
                  color: MeizuTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (_amountInput.isEmpty)
            const Text(
              '请输入金额',
              style: TextStyle(
                fontSize: 14,
                color: MeizuTheme.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium),
      child: Row(
        children: [
          // 支出/收入切换
          Container(
            decoration: BoxDecoration(
              color: MeizuTheme.meizuBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeButton(
                  label: '支出',
                  isSelected: _selectedType == BillType.expense,
                  onTap: () => setState(() => _selectedType = BillType.expense),
                ),
                _buildTypeButton(
                  label: '收入',
                  isSelected: _selectedType == BillType.income,
                  onTap: () => setState(() => _selectedType = BillType.income),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 日期选择
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MeizuTheme.spaceMedium,
                vertical: MeizuTheme.spaceSmall,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: MeizuTheme.textSecondary,
                  ),
                  const SizedBox(width: MeizuTheme.spaceSmall),
                  Text(
                    '${_selectedDate.month}月${_selectedDate.day}日',
                    style: const TextStyle(
                      fontSize: 14,
                      color: MeizuTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MeizuTheme.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: MeizuTheme.spaceMedium,
          vertical: MeizuTheme.spaceSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? MeizuTheme.meizuBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(MeizuTheme.radiusSmall),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : MeizuTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _selectedType == BillType.expense
        ? ref.watch(categoryProvider).expenseCategories
        : ref.watch(categoryProvider).incomeCategories;

    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.all(MeizuTheme.spaceMedium),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? MeizuTheme.cardDark
              : MeizuTheme.cardWhite,
          borderRadius: BorderRadius.circular(MeizuTheme.radiusLarge),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(MeizuTheme.spaceMedium),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.9,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategoryId == category.id;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = category.id),
              child: AnimatedContainer(
                duration: MeizuTheme.animationFast,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
                  border: isSelected
                      ? Border.all(color: category.color, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(MeizuTheme.radiusMedium),
                      ),
                      child: Center(
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? category.color
                            : MeizuTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MeizuTheme.spaceMedium),
      child: TextField(
        controller: _noteController,
        onChanged: (value) => setState(() => _note = value),
        decoration: InputDecoration(
          hintText: '添加备注...',
          prefixIcon:
              const Icon(Icons.edit_note, color: MeizuTheme.textTertiary),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.all(MeizuTheme.spaceMedium),
      child: Column(
        children: [
          Row(
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
              _buildActionButton(Icons.backspace, _onBackspace),
            ],
          ),
          Row(
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
              _buildActionButton(Icons.edit_note, _toggleNote),
            ],
          ),
          Row(
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
              _buildActionButton(Icons.calendar_today, _selectDate),
            ],
          ),
          Row(
            children: [
              _buildNumberButton('.', flex: 1),
              _buildNumberButton('0', flex: 1),
              _buildNumberButton('00', flex: 1),
              _buildActionButton(Icons.check, _saveBill, isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _onNumberPressed(number),
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: MeizuTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap,
      {bool isPrimary = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isPrimary ? MeizuTheme.meizuBlue : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MeizuTheme.radiusMedium),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : MeizuTheme.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _onNumberPressed(String number) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput.length < 10) {
        _amountInput += number;
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput.isNotEmpty) {
        _amountInput = _amountInput.substring(0, _amountInput.length - 1);
      }
    });
  }

  void _toggleNote() {
    // 显示备注输入
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: MeizuTheme.spaceMedium,
          right: MeizuTheme.spaceMedium,
          top: MeizuTheme.spaceMedium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '添加备注...',
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() => _note = value),
            ),
            const SizedBox(height: MeizuTheme.spaceMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveBill() async {
    if (_amountInput.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额并选择分类')),
      );
      return;
    }

    final amount = MoneyUtil.parseInputToFen(_amountInput);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金额必须大于0')),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    if (widget.editBill != null) {
      // 更新
      final updated = widget.editBill!.copyWith(
        amount: amount,
        categoryId: _selectedCategoryId!,
        type: _selectedType,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        date: _selectedDate,
      );
      await BillDao.update(updated);
    } else {
      // 新建
      final bill = Bill.create(
        amount: amount,
        categoryId: _selectedCategoryId!,
        type: _selectedType,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        date: _selectedDate,
      );
      await BillDao.insert(bill);
    }

    if (mounted) {
      ref.read(billProvider.notifier).loadBills();
      Navigator.pop(context);
    }
  }
}
