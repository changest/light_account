import 'package:sqflite/sqflite.dart';
import '../../models/bill_model.dart';
import 'db_helper.dart';

/// 账单数据访问对象
class BillDao {
  /// 插入账单
  static Future<String> insert(Bill bill) async {
    final Database db = await DBHelper.database;
    await db.insert(
      'bills',
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return bill.id;
  }

  /// 批量插入账单
  static Future<void> insertBatch(List<Bill> bills) async {
    final Database db = await DBHelper.database;
    final batch = db.batch();
    for (final bill in bills) {
      batch.insert('bills', bill.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  /// 更新账单
  static Future<int> update(Bill bill) async {
    final Database db = await DBHelper.database;
    return await db.update(
      'bills',
      bill.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  /// 软删除账单
  static Future<int> softDelete(String id) async {
    final Database db = await DBHelper.database;
    return await db.update(
      'bills',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 硬删除账单
  static Future<int> delete(String id) async {
    final Database db = await DBHelper.database;
    return await db.delete(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据 ID 查询账单
  static Future<Bill?> getById(String id) async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Bill.fromMap(maps.first);
  }

  /// 查询所有未删除账单
  static Future<List<Bill>> getAll() async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'is_deleted = 0',
      orderBy: 'date DESC',
    );
    return maps.map((map) => Bill.fromMap(map)).toList();
  }

  /// 根据日期范围查询账单
  static Future<List<Bill>> getByDateRange(DateTime start, DateTime end) async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'date >= ? AND date < ? AND is_deleted = 0',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Bill.fromMap(map)).toList();
  }

  /// 查询某天的账单
  static Future<List<Bill>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return getByDateRange(start, end);
  }

  /// 查询某周的账单
  static Future<List<Bill>> getByWeek(DateTime date) async {
    // 获取本周一
    final weekday = date.weekday;
    final start = DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
    final end = start.add(const Duration(days: 7));
    return getByDateRange(start, end);
  }

  /// 查询某月的账单
  static Future<List<Bill>> getByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return getByDateRange(start, end);
  }

  /// 根据分类查询账单
  static Future<List<Bill>> getByCategory(String categoryId) async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'category_id = ? AND is_deleted = 0',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Bill.fromMap(map)).toList();
  }

  /// 获取总支出金额（分）
  static Future<int> getTotalExpense() async {
    final Database db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM bills
      WHERE type = 0 AND is_deleted = 0
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  /// 获取总收入金额（分）
  static Future<int> getTotalIncome() async {
    final Database db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM bills
      WHERE type = 1 AND is_deleted = 0
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  /// 获取指定日期范围内的支出
  static Future<int> getExpenseByDateRange(DateTime start, DateTime end) async {
    final Database db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM bills
      WHERE type = 0 AND is_deleted = 0 AND date >= ? AND date < ?
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    return (result.first['total'] as int?) ?? 0;
  }

  /// 获取指定日期范围内的收入
  static Future<int> getIncomeByDateRange(DateTime start, DateTime end) async {
    final Database db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM bills
      WHERE type = 1 AND is_deleted = 0 AND date >= ? AND date < ?
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    return (result.first['total'] as int?) ?? 0;
  }

  /// 获取各分类统计（用于图表）
  static Future<List<Map<String, dynamic>>> getCategoryStats(
    DateTime start,
    DateTime end, {
    BillType? type,
  }) async {
    final Database db = await DBHelper.database;
    String whereClause = 'is_deleted = 0 AND date >= ? AND date < ?';
    List<dynamic> whereArgs = [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch];

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.index);
    }

    final result = await db.rawQuery('''
      SELECT category_id, SUM(amount) as total, COUNT(*) as count
      FROM bills
      WHERE $whereClause
      GROUP BY category_id
      ORDER BY total DESC
    ''', whereArgs);

    return result;
  }

  /// 获取最近更新的账单（用于同步）
  static Future<List<Bill>> getUpdatedAfter(DateTime timestamp) async {
    final Database db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'updated_at > ?',
      whereArgs: [timestamp.millisecondsSinceEpoch],
      orderBy: 'updated_at ASC',
    );
    return maps.map((map) => Bill.fromMap(map)).toList();
  }

  /// 获取指定日期的最高支出
  static Future<int> getMaxExpenseByDate(DateTime date) async {
    final Database db = await DBHelper.database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final result = await db.rawQuery('''
      SELECT MAX(amount) as max_amount FROM bills
      WHERE type = 0 AND is_deleted = 0 AND date >= ? AND date < ?
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    return (result.first['max_amount'] as int?) ?? 0;
  }
}
