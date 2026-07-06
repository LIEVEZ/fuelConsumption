import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class ExpenseCompositionCard extends StatelessWidget {
  const ExpenseCompositionCard({required this.summary, super.key});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.totalCost;
    final energyRatio = total <= 0 ? 0.0 : summary.energyCost / total;
    final maintenanceRatio = total <= 0 ? 0.0 : summary.maintenanceCost / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '费用构成统计'),
            const SizedBox(height: 18),
            if (total <= 0)
              const SizedBox(height: 132, child: Center(child: Text('暂无费用记录')))
            else
              Row(
                children: [
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 34,
                        sections: [
                          PieChartSectionData(
                            value: summary.energyCost,
                            color: AppColors.sky,
                            radius: 26,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: summary.maintenanceCost,
                            color: AppColors.maintenance,
                            radius: 26,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _CompositionRow(
                          color: AppColors.sky,
                          label: '油费',
                          amount: summary.energyCost,
                          ratio: energyRatio,
                        ),
                        const SizedBox(height: 14),
                        _CompositionRow(
                          color: AppColors.maintenance,
                          label: '维修保养',
                          amount: summary.maintenanceCost,
                          ratio: maintenanceRatio,
                        ),
                      ],
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

class _CompositionRow extends StatelessWidget {
  const _CompositionRow({
    required this.color,
    required this.label,
    required this.amount,
    required this.ratio,
  });

  final Color color;
  final String label;
  final double amount;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                '${(ratio * 100).toStringAsFixed(1)}% · ${amount.toStringAsFixed(2)} 元',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
