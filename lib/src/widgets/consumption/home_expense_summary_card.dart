import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/consumption_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class HomeExpenseSummaryCard extends StatelessWidget {
  const HomeExpenseSummaryCard({
    required this.stats,
    required this.records,
    required this.maintenanceRecords,
    super.key,
  });

  final StatisticsSnapshot stats;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;

  @override
  Widget build(BuildContext context) {
    final overview = ConsumptionStatistics.expenseOverview(
      stats: stats,
      records: records,
      maintenanceRecords: maintenanceRecords,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '费用总览', subtitle: '油费、保养和优惠汇总'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ExpenseMetric(
                    label: '总支出',
                    value: overview.totalExpense.toStringAsFixed(2),
                    unit: '元',
                    color: AppColors.text,
                  ),
                ),
                Expanded(
                  child: _ExpenseMetric(
                    label: '油费总计',
                    value: overview.energyCost.toStringAsFixed(2),
                    unit: '元',
                    color: AppColors.fuel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ExpenseMetric(
                    label: '保养费用',
                    value: overview.maintenanceCost.toStringAsFixed(2),
                    unit: '元',
                    color: AppColors.maintenance,
                  ),
                ),
                Expanded(
                  child: _ExpenseMetric(
                    label: '总计优惠',
                    value: overview.totalDiscount.toStringAsFixed(2),
                    unit: '元',
                    color: AppColors.skyDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseMetric extends StatelessWidget {
  const _ExpenseMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: value,
            children: [
              TextSpan(
                text: ' $unit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSubtle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
