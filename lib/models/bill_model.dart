import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 账单类型：支出或收入
enum BillType { expense, income }

/// 账单模型
class Bill {
  final String id;
  final int amount; // 以分为单位存储，避免浮点误差
  final String categoryId;
  final BillType type;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? syncDeviceId;
  final bool isDeleted;

  const Bill({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.syncDeviceId,
    this.isDeleted = false,
  });

  /// 创建新账单
  factory Bill.create({
    required int amount,
    required String categoryId,
    required BillType type,
    String? note,
    DateTime? date,
    String? syncDeviceId,
  }) {
    final now = DateTime.now();
    return Bill(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: categoryId,
      type: type,
      note: note,
      date: date ?? now,
      createdAt: now,
      updatedAt: now,
      syncDeviceId: syncDeviceId,
    );
  }

  /// 从数据库 Map 创建
  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as String,
      amount: map['amount'] as int,
      categoryId: map['category_id'] as String,
      type: BillType.values[map['type'] as int],
      note: map['note'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncDeviceId: map['sync_device_id'] as String?,
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'type': type.index,
      'note': note,
      'date': date.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_device_id': syncDeviceId,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// 复制并修改
  Bill copyWith({
    String? id,
    int? amount,
    String? categoryId,
    BillType? type,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncDeviceId,
    bool? isDeleted,
  }) {
    return Bill(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncDeviceId: syncDeviceId ?? this.syncDeviceId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// 获取金额（元）
  double get amountYuan => amount / 100.0;

  /// 是否支出
  bool get isExpense => type == BillType.expense;

  /// 是否收入
  bool get isIncome => type == BillType.income;

  @override
  String toString() {
    return 'Bill{id: $id, amount: $amount, type: $type, categoryId: $categoryId, date: $date}';
  }
}

/// 分类类型
enum CategoryType { expense, income, all }

/// 分类模型
class Category {
  final String id;
  final String name;
  final String icon; // Emoji 或图标名
  final int colorValue;
  final CategoryType type;
  final int sortOrder;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
    this.sortOrder = 0,
    this.isDefault = false,
  });

  /// 创建新分类
  factory Category.create({
    required String name,
    required String icon,
    required Color color,
    required CategoryType type,
    int sortOrder = 0,
  }) {
    return Category(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      colorValue: color.value,
      type: type,
      sortOrder: sortOrder,
    );
  }

  /// 从数据库 Map 创建
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colorValue: map['color'] as int,
      type: CategoryType.values[map['type'] as int],
      sortOrder: map['sort_order'] as int? ?? 0,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': colorValue,
      'type': type.index,
      'sort_order': sortOrder,
      'is_default': isDefault ? 1 : 0,
    };
  }

  /// 颜色
  Color get color => Color(colorValue);

  /// 复制并修改
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? colorValue,
    CategoryType? type,
    int? sortOrder,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, type: $type}';
  }
}

/// 预设分类数据
class DefaultCategories {
  static List<Category> get expenseCategories => [
    Category(
      id: 'cat_dining',
      name: '餐饮',
      icon: '🍔',
      colorValue: 0xFFFF6B6B,
      type: CategoryType.expense,
      sortOrder: 0,
      isDefault: true,
    ),
    Category(
      id: 'cat_transport',
      name: '交通',
      icon: '🚗',
      colorValue: 0xFF4ECDC4,
      type: CategoryType.expense,
      sortOrder: 1,
      isDefault: true,
    ),
    Category(
      id: 'cat_shopping',
      name: '购物',
      icon: '🛍️',
      colorValue: 0xFF95E1D3,
      type: CategoryType.expense,
      sortOrder: 2,
      isDefault: true,
    ),
    Category(
      id: 'cat_entertainment',
      name: '娱乐',
      icon: '🎮',
      colorValue: 0xFFF38181,
      type: CategoryType.expense,
      sortOrder: 3,
      isDefault: true,
    ),
    Category(
      id: 'cat_housing',
      name: '居住',
      icon: '🏠',
      colorValue: 0xFFAA96DA,
      type: CategoryType.expense,
      sortOrder: 4,
      isDefault: true,
    ),
    Category(
      id: 'cat_medical',
      name: '医疗',
      icon: '💊',
      colorValue: 0xFFFCBAD3,
      type: CategoryType.expense,
      sortOrder: 5,
      isDefault: true,
    ),
    Category(
      id: 'cat_education',
      name: '教育',
      icon: '📚',
      colorValue: 0xFFFFD93D,
      type: CategoryType.expense,
      sortOrder: 6,
      isDefault: true,
    ),
    Category(
      id: 'cat_other_expense',
      name: '其他',
      icon: '📦',
      colorValue: 0xFFCCCCCC,
      type: CategoryType.expense,
      sortOrder: 99,
      isDefault: true,
    ),
  ];

  static List<Category> get incomeCategories => [
    Category(
      id: 'cat_salary',
      name: '工资',
      icon: '💰',
      colorValue: 0xFF4CAF50,
      type: CategoryType.income,
      sortOrder: 0,
      isDefault: true,
    ),
    Category(
      id: 'cat_bonus',
      name: '奖金',
      icon: '🧧',
      colorValue: 0xFF8BC34A,
      type: CategoryType.income,
      sortOrder: 1,
      isDefault: true,
    ),
    Category(
      id: 'cat_investment',
      name: '理财',
      icon: '📈',
      colorValue: 0xFFCDDC39,
      type: CategoryType.income,
      sortOrder: 2,
      isDefault: true,
    ),
    Category(
      id: 'cat_parttime',
      name: '兼职',
      icon: '💼',
      colorValue: 0xFFFFEB3B,
      type: CategoryType.income,
      sortOrder: 3,
      isDefault: true,
    ),
    Category(
      id: 'cat_other_income',
      name: '其他',
      icon: '💵',
      colorValue: 0xFFCCCCCC,
      type: CategoryType.income,
      sortOrder: 99,
      isDefault: true,
    ),
  ];

  static List<Category> get all => [
    ...expenseCategories,
    ...incomeCategories,
  ];
}
