import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/category_dao.dart';
import '../models/bill_model.dart';

/// 分类列表状态
class CategoryState {
  final List<Category> categories;
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;
  final bool isLoading;

  const CategoryState({
    this.categories = const [],
    this.expenseCategories = const [],
    this.incomeCategories = const [],
    this.isLoading = false,
  });

  CategoryState copyWith({
    List<Category>? categories,
    List<Category>? expenseCategories,
    List<Category>? incomeCategories,
    bool? isLoading,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 分类状态管理器
class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(const CategoryState()) {
    loadCategories();
  }

  /// 加载所有分类
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true);

    try {
      final allCategories = await CategoryDao.getAll();
      final expenseCats = await CategoryDao.getExpenseCategories();
      final incomeCats = await CategoryDao.getIncomeCategories();

      state = state.copyWith(
        categories: allCategories,
        expenseCategories: expenseCats,
        incomeCategories: incomeCats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 添加分类
  Future<void> addCategory(Category category) async {
    await CategoryDao.insert(category);
    await loadCategories();
  }

  /// 更新分类
  Future<void> updateCategory(Category category) async {
    await CategoryDao.update(category);
    await loadCategories();
  }

  /// 删除分类
  Future<bool> deleteCategory(String id) async {
    try {
      await CategoryDao.delete(id);
      await loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 根据ID获取分类
  Category? getCategoryById(String id) {
    try {
      return state.categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// 分类 Provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier();
});

/// 当前选中分类 Provider
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);
