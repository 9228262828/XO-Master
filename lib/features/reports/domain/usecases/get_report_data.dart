import '../../../categories/domain/entities/category.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';

class CategoryExpenseData {
  const CategoryExpenseData({
    required this.category,
    required this.total,
    required this.count,
    required this.percentage,
  });

  final Category category;
  final double total;
  final int count;
  final double percentage;
}

class DailyExpenseData {
  const DailyExpenseData({required this.date, required this.total});
  final DateTime date;
  final double total;
}

class MonthlyExpenseData {
  const MonthlyExpenseData({required this.month, required this.total});
  final DateTime month;
  final double total;
}

class GetCategoryBreakdown {
  const GetCategoryBreakdown(this._expenseRepo, this._categoryRepo);

  final ExpenseRepository _expenseRepo;
  final CategoryRepository _categoryRepo;

  Future<List<CategoryExpenseData>> call(DateTime start, DateTime end) async {
    final expenses = await _expenseRepo.getExpensesByDateRange(start, end);
    final categories = await _categoryRepo.getAllCategories();
    final categoryMap = {for (final c in categories) c.id: c};

    final totals = <String, double>{};
    final counts = <String, int>{};
    double grandTotal = 0;

    for (final expense in expenses) {
      totals[expense.categoryId] = (totals[expense.categoryId] ?? 0) + expense.amount;
      counts[expense.categoryId] = (counts[expense.categoryId] ?? 0) + 1;
      grandTotal += expense.amount;
    }

    final result = totals.entries
        .where((e) => categoryMap.containsKey(e.key))
        .map((e) => CategoryExpenseData(
              category: categoryMap[e.key]!,
              total: e.value,
              count: counts[e.key] ?? 0,
              percentage: grandTotal > 0 ? (e.value / grandTotal) * 100 : 0,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return result;
  }
}

class GetDailyExpenses {
  const GetDailyExpenses(this._repository);
  final ExpenseRepository _repository;

  Future<List<DailyExpenseData>> call(DateTime start, DateTime end) async {
    final expenses = await _repository.getExpensesByDateRange(start, end);
    final dailyTotals = <String, double>{};

    for (final expense in expenses) {
      final key = '${expense.date.year}-${expense.date.month}-${expense.date.day}';
      dailyTotals[key] = (dailyTotals[key] ?? 0) + expense.amount;
    }

    final result = <DailyExpenseData>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDay)) {
      final key = '${current.year}-${current.month}-${current.day}';
      result.add(DailyExpenseData(date: current, total: dailyTotals[key] ?? 0));
      current = current.add(const Duration(days: 1));
    }

    return result;
  }
}

class GetMonthlyExpenses {
  const GetMonthlyExpenses(this._repository);
  final ExpenseRepository _repository;

  Future<List<MonthlyExpenseData>> call(int monthsBack) async {
    final now = DateTime.now();
    final result = <MonthlyExpenseData>[];

    for (int i = monthsBack - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final total = await _repository.getTotalByDateRange(start, end);
      result.add(MonthlyExpenseData(month: month, total: total));
    }

    return result;
  }
}
