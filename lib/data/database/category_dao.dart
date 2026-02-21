import 'package:sqflite/sqflite.dart';
import '../../models/bill_model.dart';
import 'db_helper.dart';

/// 分类数据访问对象
class CategoryDao {
  /// 插入分类
  static Future<String> insert(Category category) async {
    final Database db = await DBHelper.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return category.id;
  }

  /// 批量插入分类
  static Future<void> insertBatch(List<Category> categories) async {
    final Database db = await DBHelper.database;
    final batch = db.batch();
    for (final category in categories) {
      batch.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  /// 更新分类
  static Future<int> update(Category category) async {
    final Database db = await DBHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// 删除分类（仅允许删除非默认分类）
  static Future<int> delete(String id) async {
    final Database db = await DBHelper.database;
    // 先检查是否为默认分类
    final category = await getById(id);
    if (category?.isDefault == true) {
      throw Exception('默认分类不能删除');
    }
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据 ID 查询分类
  static Future<Category?> getById(String id) async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// 查询所有分类
  static Future<List<Category>> getAll() async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'sort_order ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// 根据类型查询分类
  static Future<List<Category>> getByType(CategoryType type) async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ? OR type = ?',
      whereArgs: [type.index, CategoryType.all.index],
      orderBy: 'sort_order ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// 查询支出分类
  static Future<List<Category>> getExpenseCategories() async {
    return getByType(CategoryType.expense);
  }

  /// 查询收入分类
  static Future<List<Category>> getIncomeCategories() async {
    return getByType(CategoryType.income);
  }

  /// 获取分类使用次数统计
  static Future<Map<String, int>> getCategoryUsageCount() async {
    final Database db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT category_id, COUNT(*) as count
      FROM bills
      WHERE is_deleted = 0
      GROUP BY category_id
    ''');
    return {
      for (var row in result) row['category_id'] as String: row['count'] as int,
    };
  }

  /// 检查分类是否有账单
  static Future<bool> hasBills(String categoryId) async {
    final Database db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM bills
      WHERE category_id = ? AND is_deleted = 0
    ''', [categoryId]);
    return (result.first['count'] as int) > 0;
  }

  /// 获取最大排序号
  static Future<int> getMaxSortOrder() async {
    final Database db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT MAX(sort_order) as max_order FROM categories
    ''');
    return (result.first['max_order'] as int?) ?? 0;
  }

  /// 重置为默认分类
  static Future<void> resetToDefault() async {
    final Database db = await DBHelper.database;
    // 删除所有非默认分类
    await db.delete(
      'categories',
      where: 'is_default = 0',
    );
    // 重新插入默认分类
    await DBHelper.resetDefaultCategories(db);
  }
}
