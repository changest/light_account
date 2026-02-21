import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/bill_dao.dart';
import '../models/bill_model.dart';

/// 账单列表状态
class BillState {
  final List<Bill> bills;
  final int totalExpense;
  final int totalIncome;
  final bool isLoading;
  final DateTime selectedDate;
  final ViewType viewType;

  const BillState({
    this.bills = const [],
    this.totalExpense = 0,
    this.totalIncome = 0,
    this.isLoading = false,
    required this.selectedDate,
    this.viewType = ViewType.day,
  });

  BillState copyWith({
    List<Bill>? bills,
    int? totalExpense,
    int? totalIncome,
    bool? isLoading,
    DateTime? selectedDate,
    ViewType? viewType,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      totalExpense: totalExpense ?? this.totalExpense,
      totalIncome: totalIncome ?? this.totalIncome,
      isLoading: isLoading ?? this.isLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      viewType: viewType ?? this.viewType,
    );
  }

  int get balance => totalIncome - totalExpense;
}

enum ViewType { day, week, month }

/// 账单状态管理器
class BillNotifier extends StateNotifier<BillState> {
  BillNotifier() : super(BillState(selectedDate: DateTime.now())) {
    loadBills();
  }

  /// 加载账单数据
  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true);

    try {
      List<Bill> bills;
      int expense = 0;
      int income = 0;

      switch (state.viewType) {
        case ViewType.day:
          bills = await BillDao.getByDate(state.selectedDate);
          final start = DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day);
          final end = start.add(const Duration(days: 1));
          expense = await BillDao.getExpenseByDateRange(start, end);
          income = await BillDao.getIncomeByDateRange(start, end);
          break;
        case ViewType.week:
          bills = await BillDao.getByWeek(state.selectedDate);
          final start = DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day)
              .subtract(Duration(days: state.selectedDate.weekday - 1));
          final end = start.add(const Duration(days: 7));
          expense = await BillDao.getExpenseByDateRange(start, end);
          income = await BillDao.getIncomeByDateRange(start, end);
          break;
        case ViewType.month:
          bills = await BillDao.getByMonth(state.selectedDate.year, state.selectedDate.month);
          final start = DateTime(state.selectedDate.year, state.selectedDate.month, 1);
          final end = DateTime(state.selectedDate.year, state.selectedDate.month + 1, 1);
          expense = await BillDao.getExpenseByDateRange(start, end);
          income = await BillDao.getIncomeByDateRange(start, end);
          break;
      }

      state = state.copyWith(
        bills: bills,
        totalExpense: expense,
        totalIncome: income,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 添加账单
  Future<void> addBill(Bill bill) async {
    await BillDao.insert(bill);
    await loadBills();
  }

  /// 更新账单
  Future<void> updateBill(Bill bill) async {
    await BillDao.update(bill);
    await loadBills();
  }

  /// 删除账单
  Future<void> deleteBill(String id) async {
    await BillDao.softDelete(id);
    await loadBills();
  }

  /// 切换视图类型
  void setViewType(ViewType type) {
    state = state.copyWith(viewType: type);
    loadBills();
  }

  /// 设置选中日期
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadBills();
  }

  /// 切换到上一天/周/月
  void previousPeriod() {
    switch (state.viewType) {
      case ViewType.day:
        state = state.copyWith(
          selectedDate: state.selectedDate.subtract(const Duration(days: 1)),
        );
        break;
      case ViewType.week:
        state = state.copyWith(
          selectedDate: state.selectedDate.subtract(const Duration(days: 7)),
        );
        break;
      case ViewType.month:
        final newMonth = state.selectedDate.month - 1;
        final newYear = newMonth < 1 ? state.selectedDate.year - 1 : state.selectedDate.year;
        state = state.copyWith(
          selectedDate: DateTime(newYear, newMonth < 1 ? 12 : newMonth),
        );
        break;
    }
    loadBills();
  }

  /// 切换到下一天/周/月
  void nextPeriod() {
    switch (state.viewType) {
      case ViewType.day:
        state = state.copyWith(
          selectedDate: state.selectedDate.add(const Duration(days: 1)),
        );
        break;
      case ViewType.week:
        state = state.copyWith(
          selectedDate: state.selectedDate.add(const Duration(days: 7)),
        );
        break;
      case ViewType.month:
        final newMonth = state.selectedDate.month + 1;
        final newYear = newMonth > 12 ? state.selectedDate.year + 1 : state.selectedDate.year;
        state = state.copyWith(
          selectedDate: DateTime(newYear, newMonth > 12 ? 1 : newMonth),
        );
        break;
    }
    loadBills();
  }
}

/// 账单 Provider
final billProvider = StateNotifierProvider<BillNotifier, BillState>((ref) {
  return BillNotifier();
});
