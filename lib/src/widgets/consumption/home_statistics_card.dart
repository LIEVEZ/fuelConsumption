import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/consumption_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class HomeStatisticsCard extends StatelessWidget {
  const HomeStatisticsCard({
    required this.stats,
    required this.records,
    super.key,
  });

  final StatisticsSnapshot stats;
  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final latestDistance = ConsumptionStatistics.averageDailyDistance(records);
    final totalDiscount = ConsumptionStatistics.totalDiscount(records);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: SectionHeader(title: '统计')),
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
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 24) / 3;
                return Wrap(
                  spacing: 12,
                  runSpacing: 24,
                  children: [
                    _StatCell(
                      width: width,
                      label: '平均油耗',
                      value: stats.averageConsumptionLabel,
                      unit: '',
                      highlighted: true,
                    ),
                    _StatCell(
                      width: width,
                      label: '平均行程',
                      value: latestDistance.toStringAsFixed(2),
                      unit: '公里/天',
                    ),
                    _StatCell(
                      width: width,
                      label: '平均油费',
                      value: stats.costPerKm.toStringAsFixed(2),
                      unit: '元/公里',
                      highlighted: true,
                    ),
                    _StatCell(
                      width: width,
                      label: '累计行程',
                      value: stats.totalDistanceKm.toStringAsFixed(0),
                      unit: '公里',
                    ),
                    _StatCell(
                      width: width,
                      label: '累计油费',
                      value: stats.totalCost.toStringAsFixed(2),
                      unit: '元',
                    ),
                    _StatCell(
                      width: width,
                      label: '总计优惠',
                      value: totalDiscount.toStringAsFixed(2),
                      unit: '元',
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

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.width,
    required this.label,
    required this.value,
    required this.unit,
    this.highlighted = false,
  });

  final double width;
  final String label;
  final String value;
  final String unit;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final displayValue = parseLeadingNumber(value)?.toStringAsFixed(2) ?? value;
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
          Text(
            displayValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: highlighted ? AppColors.skyDark : AppColors.text,
              fontWeight: FontWeight.w900,
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
