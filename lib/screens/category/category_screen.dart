import 'package:flutter/material.dart';
import '../../core/theme/meizu_theme.dart';

/// 分类管理页面
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MeizuTheme.backgroundDark : MeizuTheme.background,
      appBar: AppBar(
        title: const Text('分类管理'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('分类管理功能开发中...'),
      ),
    );
  }
}
