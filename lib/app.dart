import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/add/add_bill_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/sync/sync_screen.dart';

/// 应用主组件
class LightAccountApp extends StatelessWidget {
  const LightAccountApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 设置系统UI样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: '轻账',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddBillScreen(),
        '/category': (context) => const CategoryScreen(),
        '/stats': (context) => const StatsScreen(),
        '/sync': (context) => const SyncScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
