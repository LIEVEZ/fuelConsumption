import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class AnnualExpenseCard extends StatelessWidget {
  const AnnualExpenseCard({required this.years, super.key});

  final List<AnnualExpense> years;

  static const _energyColor = AppColors.sky;
  static const _maintenanceColor = AppColors.maintenance;

  @override
  Widget build(BuildContext context) {
    final maxY = years.isEmpty
        ? 0.0
        : years.map((year) => year.total).reduce(math.max);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SectionHeader(title: '年度支出统计')),
                const _LegendDot(color: _energyColor, label: '油费'),
                const SizedBox(width: 10),
                const _LegendDot(color: _maintenanceColor, label: '维修保养'),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 240,
              child: years.isEmpty
                  ? const Center(child: Text('暂无费用记录'))
                  : BarChart(
                      BarChartData(
                        maxY: maxY <= 0 ? 1 : maxY * 1.18,
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: AppColors.border,
                            dashArray: [8, 8],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              getTitlesWidget: (value, meta) => Text(
                                _compactMoney(value),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= years.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('${years[index].year}'),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var index = 0; index < years.length; index++)
                            BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: years[index].total,
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                      0,
                                      years[index].energy,
                                      _energyColor,
                                    ),
                                    BarChartRodStackItem(
                                      years[index].energy,
                                      years[index].total,
                                      _maintenanceColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

String _compactMoney(double value) {
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(1)}万';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
  return value.toStringAsFixed(0);
}
