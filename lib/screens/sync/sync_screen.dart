import 'package:flutter/material.dart';
import '../../core/theme/meizu_theme.dart';

/// 局域网同步页面
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MeizuTheme.backgroundDark : MeizuTheme.background,
      appBar: AppBar(
        title: const Text('局域网同步'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('局域网同步功能开发中...'),
      ),
    );
  }
}
