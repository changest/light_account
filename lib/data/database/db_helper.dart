import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// 数据库帮助类
/// 管理 SQLite 数据库的初始化和版本控制
class DBHelper {
  static const String _databaseName = 'light_account.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  /// 获取数据库实例
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  static Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  static Future<void> _onCreate(Database db, int version) async {
    // 创建账单表
    await db.execute('''
      CREATE TABLE bills (
        id TEXT PRIMARY KEY,
        amount INTEGER NOT NULL,
        category_id TEXT NOT NULL,
        type INTEGER NOT NULL,
        note TEXT,
        date INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_device_id TEXT,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type INTEGER NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 创建同步记录表
    await db.execute('''
      CREATE TABLE sync_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        device_name TEXT,
        last_sync_at INTEGER,
        sync_count INTEGER DEFAULT 0
      )
    ''');

    // 创建设备配对表
    await db.execute('''
      CREATE TABLE device_pairs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL UNIQUE,
        device_name TEXT NOT NULL,
        token TEXT NOT NULL,
        paired_at INTEGER NOT NULL,
        last_sync_at INTEGER
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_bills_date ON bills(date)');
    await db.execute('CREATE INDEX idx_bills_category ON bills(category_id)');
    await db.execute('CREATE INDEX idx_bills_updated ON bills(updated_at)');
    await db.execute('CREATE INDEX idx_bills_deleted ON bills(is_deleted)');

    // 插入默认分类
    await _insertDefaultCategories(db);
  }

  /// 插入默认分类数据
  static Future<void> _insertDefaultCategories(Database db) async {
    final List<Map<String, dynamic>> defaultCategories = [
      // 支出分类
      {'id': 'cat_dining', 'name': '餐饮', 'icon': '🍔', 'color': 0xFFFF6B6B, 'type': 0, 'sort_order': 0, 'is_default': 1},
      {'id': 'cat_transport', 'name': '交通', 'icon': '🚗', 'color': 0xFF4ECDC4, 'type': 0, 'sort_order': 1, 'is_default': 1},
      {'id': 'cat_shopping', 'name': '购物', 'icon': '🛍️', 'color': 0xFF95E1D3, 'type': 0, 'sort_order': 2, 'is_default': 1},
      {'id': 'cat_entertainment', 'name': '娱乐', 'icon': '🎮', 'color': 0xFFF38181, 'type': 0, 'sort_order': 3, 'is_default': 1},
      {'id': 'cat_housing', 'name': '居住', 'icon': '🏠', 'color': 0xFFAA96DA, 'type': 0, 'sort_order': 4, 'is_default': 1},
      {'id': 'cat_medical', 'name': '医疗', 'icon': '💊', 'color': 0xFFFCBAD3, 'type': 0, 'sort_order': 5, 'is_default': 1},
      {'id': 'cat_education', 'name': '教育', 'icon': '📚', 'color': 0xFFFFD93D, 'type': 0, 'sort_order': 6, 'is_default': 1},
      {'id': 'cat_other_expense', 'name': '其他', 'icon': '📦', 'color': 0xFFCCCCCC, 'type': 0, 'sort_order': 99, 'is_default': 1},
      // 收入分类
      {'id': 'cat_salary', 'name': '工资', 'icon': '💰', 'color': 0xFF4CAF50, 'type': 1, 'sort_order': 0, 'is_default': 1},
      {'id': 'cat_bonus', 'name': '奖金', 'icon': '🧧', 'color': 0xFF8BC34A, 'type': 1, 'sort_order': 1, 'is_default': 1},
      {'id': 'cat_investment', 'name': '理财', 'icon': '📈', 'color': 0xFFCDDC39, 'type': 1, 'sort_order': 2, 'is_default': 1},
      {'id': 'cat_parttime', 'name': '兼职', 'icon': '💼', 'color': 0xFFFFEB3B, 'type': 1, 'sort_order': 3, 'is_default': 1},
      {'id': 'cat_other_income', 'name': '其他', 'icon': '💵', 'color': 0xFFCCCCCC, 'type': 1, 'sort_order': 99, 'is_default': 1},
    ];

    final batch = db.batch();
    for (final category in defaultCategories) {
      batch.insert('categories', category);
    }
    await batch.commit();
  }

  /// 数据库升级
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库版本升级
    if (oldVersion < 2) {
      // 版本 2 的升级逻辑
    }
  }

  /// 重置默认分类
  static Future<void> resetDefaultCategories(Database db) async {
    final List<Map<String, dynamic>> defaultCategories = [
      // 支出分类
      {'id': 'cat_dining', 'name': '餐饮', 'icon': '🍔', 'color': 0xFFFF6B6B, 'type': 0, 'sort_order': 0, 'is_default': 1},
      {'id': 'cat_transport', 'name': '交通', 'icon': '🚗', 'color': 0xFF4ECDC4, 'type': 0, 'sort_order': 1, 'is_default': 1},
      {'id': 'cat_shopping', 'name': '购物', 'icon': '🛍️', 'color': 0xFF95E1D3, 'type': 0, 'sort_order': 2, 'is_default': 1},
      {'id': 'cat_entertainment', 'name': '娱乐', 'icon': '🎮', 'color': 0xFFF38181, 'type': 0, 'sort_order': 3, 'is_default': 1},
      {'id': 'cat_housing', 'name': '居住', 'icon': '🏠', 'color': 0xFFAA96DA, 'type': 0, 'sort_order': 4, 'is_default': 1},
      {'id': 'cat_medical', 'name': '医疗', 'icon': '💊', 'color': 0xFFFCBAD3, 'type': 0, 'sort_order': 5, 'is_default': 1},
      {'id': 'cat_education', 'name': '教育', 'icon': '📚', 'color': 0xFFFFD93D, 'type': 0, 'sort_order': 6, 'is_default': 1},
      {'id': 'cat_other_expense', 'name': '其他', 'icon': '📦', 'color': 0xFFCCCCCC, 'type': 0, 'sort_order': 99, 'is_default': 1},
      // 收入分类
      {'id': 'cat_salary', 'name': '工资', 'icon': '💰', 'color': 0xFF4CAF50, 'type': 1, 'sort_order': 0, 'is_default': 1},
      {'id': 'cat_bonus', 'name': '奖金', 'icon': '🧧', 'color': 0xFF8BC34A, 'type': 1, 'sort_order': 1, 'is_default': 1},
      {'id': 'cat_investment', 'name': '理财', 'icon': '📈', 'color': 0xFFCDDC39, 'type': 1, 'sort_order': 2, 'is_default': 1},
      {'id': 'cat_parttime', 'name': '兼职', 'icon': '💼', 'color': 0xFFFFEB3B, 'type': 1, 'sort_order': 3, 'is_default': 1},
      {'id': 'cat_other_income', 'name': '其他', 'icon': '💵', 'color': 0xFFCCCCCC, 'type': 1, 'sort_order': 99, 'is_default': 1},
    ];

    // 使用 REPLACE 避免重复插入
    final batch = db.batch();
    for (final category in defaultCategories) {
      batch.insert('categories', category, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  /// 关闭数据库
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 删除数据库
  static Future<void> deleteDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
