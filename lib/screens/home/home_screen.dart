import 'package:flutter/material.dart';
import '../../core/theme/meizu_theme.dart';
import '../../core/utils/money_util.dart';
import '../../data/database/bill_dao.dart';
import '../../models/bill_model.dart';
import '../../providers/bill_provider.dart';
import '../../services/kimi_service.dart';
import '../../widgets/meizu_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/amount_card.dart';
import 'widgets/bill_list.dart';
import 'widgets/date_header.dart';
import 'widgets/view_switcher.dart';
import 'widgets/voice_button.dart';

/// 首页
/// 展示账单列表、统计金额、日期导航、语音记账
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showVoiceButton = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MeizuTheme.backgroundDark : MeizuTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            _buildAppBar(context),
            const SizedBox(height: MeizuTheme.spaceMedium),
            // 日期导航
            const DateHeader(),
            const SizedBox(height: MeizuTheme.spaceMedium),
            // 视图切换
            const ViewSwitcher(),
            const SizedBox(height: MeizuTheme.spaceMedium),
            // 金额卡片
            const AmountCard(),
            const SizedBox(height: MeizuTheme.spaceMedium),
            // 账单列表
            const Expanded(
              child: BillList(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _showVoiceButton
          ? _buildVoiceButton()
          : _buildManualButton(context),
    );
  }

  /// 语音记账按钮
  Widget _buildVoiceButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 切换到手动记账按钮
        GestureDetector(
          onTap: () => setState(() => _showVoiceButton = false),
          child: Container(
            margin: const EdgeInsets.only(bottom: MeizuTheme.spaceSmall),
            padding: const EdgeInsets.symmetric(
              horizontal: MeizuTheme.spaceMedium,
              vertical: MeizuTheme.spaceTiny,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MeizuTheme.radiusSmall),
            ),
            child: const Text(
              '手动记账',
              style: TextStyle(
                fontSize: 12,
                color: MeizuTheme.textTertiary,
              ),
            ),
          ),
        ),
        // 语音按钮
        VoiceButton(
          onResult: (result) => _onVoiceResult(result),
        ),
      ],
    );
  }

  /// 手动记账按钮
  Widget _buildManualButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 切换到语音记账按钮
        GestureDetector(
          onTap: () => setState(() => _showVoiceButton = true),
          child: Container(
            margin: const EdgeInsets.only(bottom: MeizuTheme.spaceSmall),
            padding: const EdgeInsets.symmetric(
              horizontal: MeizuTheme.spaceMedium,
              vertical: MeizuTheme.spaceTiny,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MeizuTheme.radiusSmall),
            ),
            child: const Text(
              '语音记账',
              style: TextStyle(
                fontSize: 12,
                color: MeizuTheme.textTertiary,
              ),
            ),
          ),
        ),
        // 手动记账按钮
        MeizuFloatingButton(
          onPressed: () => _showAddBill(context),
          label: '记一笔',
        ),
      ],
    );
  }

  /// 处理语音识别结果
  void _onVoiceResult(ParseResult result) {
    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未能识别账单信息，请重试')),
      );
      return;
    }

    // 显示结果预览
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceResultPreview(
        result: result,
        onConfirm: () => _saveVoiceBill(result),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// 保存语音识别的账单
  Future<void> _saveVoiceBill(ParseResult result) async {
    // 查找分类ID
    final categoryId = await _findCategoryId(result.category, result.type);

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未找到对应分类')),
      );
      return;
    }

    // 创建账单
    final bill = Bill.create(
      amount: MoneyUtil.yuanToFen(result.amount!),
      categoryId: categoryId,
      type: result.type,
      note: result.note ?? result.rawText,
    );

    await BillDao.insert(bill);

    // 刷新列表
    ref.read(billProvider.notifier).loadBills();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('记账成功')),
      );
    }
  }

  /// 根据分类名称查找分类ID
  Future<String?> _findCategoryId(String? categoryName, BillType type) async {
    if (categoryName == null) return null;

    // 查找匹配的分类
    final categories = type == BillType.expense
        ? DefaultCategories.expenseCategories
        : DefaultCategories.incomeCategories;

    for (final category in categories) {
      if (category.name == categoryName) {
        return category.id;
      }
    }

    // 如果没找到，返回第一个分类
    return categories.firstOrNull?.id;
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MeizuTheme.spaceMedium,
        vertical: MeizuTheme.spaceSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧菜单按钮
          MeizuIconButton(
            onPressed: () => _showMenu(context),
            icon: Icons.menu,
            size: 40,
          ),
          // 标题
          const Text(
            '轻账',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // 右侧统计按钮
          MeizuIconButton(
            onPressed: () => _showStats(context),
            icon: Icons.pie_chart_outline,
            size: 40,
          ),
        ],
      ),
    );
  }

  void _showAddBill(BuildContext context) {
    Navigator.pushNamed(context, '/add');
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MenuSheet(),
    );
  }

  void _showStats(BuildContext context) {
    Navigator.pushNamed(context, '/stats');
  }
}

/// 菜单弹窗
class _MenuSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(MeizuTheme.spaceMedium),
      decoration: BoxDecoration(
        color: isDark ? MeizuTheme.cardDark : MeizuTheme.cardWhite,
        borderRadius: BorderRadius.circular(MeizuTheme.radiusXLarge),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: MeizuTheme.spaceMedium),
            // 拖动手柄
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: MeizuTheme.spaceLarge),
            // 菜单项
            _buildMenuItem(
              icon: Icons.category_outlined,
              title: '分类管理',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/category');
              },
            ),
            _buildMenuItem(
              icon: Icons.sync_outlined,
              title: '局域网同步',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/sync');
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: '设置',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const SizedBox(height: MeizuTheme.spaceLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: MeizuTheme.textSecondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: MeizuTheme.textTertiary),
      onTap: onTap,
    );
  }
}
