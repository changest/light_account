import 'package:flutter/material.dart';
import '../../core/theme/meizu_theme.dart';

/// 统计页面
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MeizuTheme.backgroundDark : MeizuTheme.background,
      appBar: AppBar(
        title: const Text('统计'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('统计功能开发中...'),
      ),
    );
  }
}
