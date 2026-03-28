import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../services/di.dart';
import '../../../../services/settings_service.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../categories/presentation/cubit/category_state.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ExpenseCubit>()..loadExpenses(),
        ),
        BlocProvider(
          create: (_) => sl<CategoryCubit>()..loadCategories(),
        ),
      ],
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyCode = SettingsService.instance.currencyCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, colorScheme),
            Expanded(
              child: BlocBuilder<ExpenseCubit, ExpenseState>(
                // Never re-render for transient operation states; keep last loaded UI.
                buildWhen: (prev, curr) =>
                    curr is ExpenseLoading ||
                    curr is ExpenseLoaded ||
                    curr is ExpenseError,
                builder: (context, state) {
                  if (state is ExpenseLoading) {
                    return const FullScreenLoader();
                  }
                  if (state is ExpenseError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<ExpenseCubit>().loadExpenses(),
                    );
                  }
                  if (state is ExpenseLoaded) {
                    return _buildContent(context, state, currencyCode, isDark, colorScheme);
                  }
                  return const FullScreenLoader();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_greeting()}!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'SpendWise',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearching
                ? IconButton(
                    key: const ValueKey('close'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      setState(() => _isSearching = false);
                      _searchController.clear();
                      context.read<ExpenseCubit>().clearSearch();
                    },
                  )
                : IconButton(
                    key: const ValueKey('search'),
                    icon: Icon(Icons.search_rounded, color: colorScheme.onSurface),
                    onPressed: () => setState(() => _isSearching = true),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ExpenseLoaded state,
    String currencyCode,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (_isSearching)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (q) => context.read<ExpenseCubit>().search(q),
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                ),
              ),
            ),
          ),
        if (!_isSearching)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: TotalBanner(
                totalAmount: state.monthTotal,
                currencyCode: currencyCode,
                todayAmount: state.todayTotal,
              ),
            ),
          ),
        if (!_isSearching)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _buildInsights(context, state, currencyCode, isDark, colorScheme),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SectionHeader(
              title: _isSearching
                  ? 'Results (${state.filteredExpenses.length})'
                  : 'Recent Transactions',
              actionLabel: !_isSearching && state.allExpenses.isNotEmpty ? 'See All' : null,
              onAction: () => context.push(AppRoutes.allExpenses),
            ),
          ),
        ),
        if (state.filteredExpenses.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: _isSearching ? 'No results found' : 'No expenses yet',
              subtitle: _isSearching
                  ? 'Try a different search term'
                  : 'Tap the + button to add your first expense',
              actionLabel: !_isSearching ? 'Add Expense' : null,
              onAction: !_isSearching ? () => context.push(AppRoutes.addExpense) : null,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                final categories = categoryState is CategoryLoaded
                    ? {for (final c in categoryState.categories) c.id: c}
                    : <String, dynamic>{};

                final displayExpenses = _isSearching
                    ? state.filteredExpenses
                    : state.allExpenses.take(20).toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      final expense = displayExpenses[index];
                      final category = categories[expense.categoryId];
                      final showDateHeader = index == 0 ||
                          !AppDateUtils.isToday(displayExpenses[index - 1].date) &&
                              AppDateUtils.isToday(expense.date) ||
                          displayExpenses[index - 1].date.day != expense.date.day;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader && !_isSearching) ...[
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
                            onTap: () => context.push(
                              AppRoutes.editExpense,
                              extra: expense,
                            ),
                            onDelete: () =>
                                context.read<ExpenseCubit>().deleteExpense(expense.id),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                    childCount: displayExpenses.length,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInsights(
    BuildContext context,
    ExpenseLoaded state,
    String currencyCode,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (state.allExpenses.isEmpty) return const SizedBox();

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final dailyAvg = daysPassed > 0 ? state.monthTotal / daysPassed : 0;
    final projectedMonthly = dailyAvg * daysInMonth;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending Insights',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Daily avg: \$${dailyAvg.toStringAsFixed(2)} · Projected: \$${projectedMonthly.toStringAsFixed(0)}/mo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
