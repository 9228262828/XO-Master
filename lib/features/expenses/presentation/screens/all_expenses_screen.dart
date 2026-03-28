import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../services/di.dart';
import '../../../../services/settings_service.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../categories/presentation/cubit/category_state.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_tile.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ExpenseCubit>()..loadExpenses()),
        BlocProvider(create: (_) => sl<CategoryCubit>()..loadCategories()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Expenses'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, _) => TextField(
                  controller: _searchController,
                  onChanged: (q) => context.read<ExpenseCubit>().search(q),
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ExpenseCubit>().clearSearch();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ExpenseCubit, ExpenseState>(
                buildWhen: (prev, curr) =>
                    curr is ExpenseLoading ||
                    curr is ExpenseLoaded ||
                    curr is ExpenseError,
                builder: (context, state) {
                  if (state is ExpenseLoading) return const FullScreenLoader();
                  if (state is ExpenseError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<ExpenseCubit>().loadExpenses(),
                    );
                  }
                  if (state is ExpenseLoaded) {
                    if (state.filteredExpenses.isEmpty) {
                      return EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'No expenses found',
                        actionLabel: 'Add Expense',
                        onAction: () => context.push(AppRoutes.addExpense),
                      );
                    }
                    return BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, categoryState) {
                        final categories = categoryState is CategoryLoaded
                            ? {for (final c in categoryState.categories) c.id: c}
                            : <String, Category>{};
                        return _buildExpenseList(context, state, categories);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.addExpense),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildExpenseList(
    BuildContext context,
    ExpenseLoaded state,
    Map<String, Category> categories,
  ) {
    final currencyCode = SettingsService.instance.currencyCode;
    final expenses = state.filteredExpenses;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        final category = categories[expense.categoryId];
        final showDateHeader = index == 0 ||
            expenses[index - 1].date.day != expense.date.day ||
            expenses[index - 1].date.month != expense.date.month;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  AppDateUtils.relativeDate(expense.date),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
            ExpenseTile(
              expense: expense,
              category: category,
              currencyCode: currencyCode,
              onTap: () => context.push(AppRoutes.editExpense, extra: expense),
              onDelete: () => context.read<ExpenseCubit>().deleteExpense(expense.id),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
