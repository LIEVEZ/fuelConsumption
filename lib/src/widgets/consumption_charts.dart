import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/consumption_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class ConsumptionTrendCard extends StatelessWidget {
  const ConsumptionTrendCard({required this.records, super.key});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final spots = ConsumptionStatistics.consumptionTrendPoints(
      records,
    ).map((point) => FlSpot(point.index.toDouble(), point.value)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SectionHeader(title: '油耗变化趋势')),
                Text(
                  '全部',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.tune, size: 20),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 300,
              child: spots.length < 2
                  ? const Center(child: Text('补能两次后显示趋势'))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: AppColors.border,
                            dashArray: [8, 8],
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: AppColors.textSubtle),
                            bottom: BorderSide(color: AppColors.textSubtle),
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(),
                          rightTitles: AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 3,
                            color: AppColors.sky,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
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

class MonthlyFuelCostCard extends StatelessWidget {
  const MonthlyFuelCostCard({required this.records, super.key});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final entries = ConsumptionStatistics.monthlyFuelCosts(records);
    return _BarChartCard(
      title: '油费月度统计',
      emptyText: '记录补能费用后显示月度统计',
      groups: entries
          .map(
            (entry) => _ChartBar(
              label: '${entry.month}月',
              value: entry.cost,
              color: AppColors.sky,
            ),
          )
          .toList(),
    );
  }
}

class AnnualConsumptionCard extends StatelessWidget {
  const AnnualConsumptionCard({required this.records, super.key});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final entries = ConsumptionStatistics.annualConsumptionComparisons(records);
    return _BarChartCard(
      title: '油耗年度对比统计',
      emptyText: '补能两次后显示年度对比',
      groups: entries
          .map(
            (entry) => _ChartBar(
              label: entry.year.toString(),
              value: entry.value,
              color: AppColors.skyDark,
            ),
          )
          .toList(),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.title,
    required this.emptyText,
    required this.groups,
  });

  final String title;
  final String emptyText;
  final List<_ChartBar> groups;

  @override
  Widget build(BuildContext context) {
    final maxValue = groups.fold<double>(
      0,
      (max, group) => group.value > max ? group.value : max,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title),
            const SizedBox(height: 18),
            SizedBox(
              height: 220,
              child: groups.isEmpty
                  ? Center(child: Text(emptyText))
                  : BarChart(
                      BarChartData(
                        maxY: maxValue <= 0 ? 1 : maxValue * 1.18,
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: AppColors.border,
                            dashArray: [6, 6],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= groups.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    groups[index].label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var index = 0; index < groups.length; index++)
                            BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: groups[index].value,
                                  width: 18,
                                  color: groups[index].color,
                                  borderRadius: BorderRadius.circular(4),
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

class _ChartBar {
  const _ChartBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}
