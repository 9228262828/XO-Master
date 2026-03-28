import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../services/di.dart';
import '../../../../services/settings_service.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import '../widgets/expense_bar_chart.dart';
import '../widgets/expense_pie_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportCubit>()..loadReport(ReportPeriod.monthly),
      child: const _ReportsContent(),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyCode = SettingsService.instance.currencyCode;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) return const FullScreenLoader();
          if (state is ReportError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<ReportCubit>().loadReport(ReportPeriod.monthly),
            );
          }
          if (state is ReportLoaded) {
            return _buildContent(context, state, currencyCode, colorScheme);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReportLoaded state,
    String currencyCode,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _PeriodSelector(
              selected: state.period,
              onChanged: (p) => context.read<ReportCubit>().loadReport(p),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildSummaryRow(state, currencyCode, isDark, colorScheme),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: SectionHeader(
              title: state.period == ReportPeriod.weekly ? 'Daily Spending' : '6-Month Trend',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildChartCard(context, state, currencyCode, isDark),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: const SectionHeader(title: 'By Category'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildPieChartCard(context, state, currencyCode, isDark),
          ),
        ),
        if (state.categoryBreakdown.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: const SectionHeader(title: 'Category Breakdown'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) {
                  final item = state.categoryBreakdown[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CategoryBreakdownTile(
                      item: item,
                      currencyCode: currencyCode,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  );
                },
                childCount: state.categoryBreakdown.length,
              ),
            ),
          ),
        ] else
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSummaryRow(
    ReportLoaded state,
    String currencyCode,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: CurrencyFormatter.format(state.totalAmount, currencyCode),
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: state.transactionCount.toString(),
            icon: Icons.receipt_long_rounded,
            color: AppColors.secondary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Average',
            value: CurrencyFormatter.formatCompact(state.averageExpense, currencyCode),
            icon: Icons.trending_up_rounded,
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    ReportLoaded state,
    String currencyCode,
    bool isDark,
  ) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: state.period == ReportPeriod.weekly
          ? WeeklyBarChart(data: state.dailyData, currencyCode: currencyCode)
          : MonthlyLineChart(data: state.monthlyData, currencyCode: currencyCode),
    );
  }

  Widget _buildPieChartCard(
    BuildContext context,
    ReportLoaded state,
    String currencyCode,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: ExpensePieChart(data: state.categoryBreakdown, currencyCode: currencyCode),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PeriodTab(
            label: 'Weekly',
            isSelected: selected == ReportPeriod.weekly,
            onTap: () => onChanged(ReportPeriod.weekly),
          ),
          _PeriodTab(
            label: 'Monthly',
            isSelected: selected == ReportPeriod.monthly,
            onTap: () => onChanged(ReportPeriod.monthly),
          ),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownTile extends StatelessWidget {
  const _CategoryBreakdownTile({
    required this.item,
    required this.currencyCode,
    required this.isDark,
    required this.colorScheme,
  });

  final dynamic item;
  final String currencyCode;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.category.icon, color: item.category.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.percentage / 100,
                    backgroundColor: item.category.color.withValues(alpha: 0.15),
                    color: item.category.color,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item.total, currencyCode),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
