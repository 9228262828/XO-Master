import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../reports/domain/usecases/get_report_data.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.data, required this.currencyCode});

  final List<DailyExpenseData> data;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (data.isEmpty) {
      return Center(
        child: Text('No data', style: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        )),
      );
    }

    final maxValue = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final adjustedMax = (maxValue > 0 ? maxValue * 1.2 : 100.0);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: adjustedMax,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '\$${data[groupIndex].total.toStringAsFixed(0)}',
                AppTextStyles.labelSmall.copyWith(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppDateUtils.formatWeekday(data[index].date),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: adjustedMax / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final isToday = AppDateUtils.isToday(entry.value.date);
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.total > 0 ? entry.value.total : 0.1,
                color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class MonthlyLineChart extends StatelessWidget {
  const MonthlyLineChart({super.key, required this.data, required this.currencyCode});

  final List<MonthlyExpenseData> data;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (data.isEmpty) {
      return Center(
        child: Text('No data', style: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        )),
      );
    }

    final maxValue = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final adjustedMax = (maxValue > 0 ? maxValue * 1.2 : 100.0);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: adjustedMax,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                '\$${spot.y.toStringAsFixed(0)}',
                AppTextStyles.labelSmall.copyWith(color: Colors.white),
              );
            }).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppDateUtils.formatMonthShort(data[index].month),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: adjustedMax / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.total);
            }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
