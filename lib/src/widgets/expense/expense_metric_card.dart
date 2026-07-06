import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class ExpenseMetricCard extends StatelessWidget {
  const ExpenseMetricCard({required this.summary, super.key});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '费用统计'),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 22,
                  children: [
                    _MetricCell(
                      width: width,
                      label: '总支出',
                      value: summary.totalCost,
                      unit: '元',
                      highlighted: true,
                    ),
                    _MetricCell(
                      width: width,
                      label: '支出/公里',
                      value: summary.costPerKm,
                      unit: '元/公里',
                    ),
                    _MetricCell(
                      width: width,
                      label: '油费/公里',
                      value: summary.energyCostPerKm,
                      unit: '元/公里',
                    ),
                    _MetricCell(
                      width: width,
                      label: '成本/天',
                      value: summary.costPerDay,
                      unit: '元/天',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.width,
    required this.label,
    required this.value,
    required this.unit,
    this.highlighted = false,
  });

  final double width;
  final String label;
  final double value;
  final String unit;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: highlighted ? AppColors.skyDark : AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSubtle),
          ),
        ],
      ),
    );
  }
}
