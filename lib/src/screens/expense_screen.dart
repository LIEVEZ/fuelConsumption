import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/expense/annual_expense_card.dart';
import 'package:fuel_consumption/src/widgets/expense/expense_detail_card.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({
    required this.vehicle,
    required this.records,
    required this.maintenanceRecords,
    super.key,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;

  @override
  Widget build(BuildContext context) {
    final summary = ExpenseSummary.from(
      vehicle: vehicle,
      records: records,
      maintenanceRecords: maintenanceRecords,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      children: [
        _ExpenseHeroCard(summary: summary),
        const SizedBox(height: 14),
        _ExpenseMetricCard(summary: summary),
        const SizedBox(height: 14),
        AnnualExpenseCard(years: summary.annualExpenses),
        const SizedBox(height: 14),
        _ExpenseCompositionCard(summary: summary),
        const SizedBox(height: 14),
        const _IncomeEmptyCard(),
        const SizedBox(height: 14),
        ExpenseDetailCard(items: summary.items),
      ],
    );
  }
}

class _ExpenseHeroCard extends StatelessWidget {
  const _ExpenseHeroCard({required this.summary});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    final companion = summary.hasCompanionDate
        ? '已相伴 ${summary.companionDays} 天'
        : '暂无用车记录';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -18,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.sky.withValues(alpha: 0.16),
                  child: Icon(
                    vehicleIcon(summary.vehicle.type),
                    color: AppColors.skyDark,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.vehicle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          summary.vehicle.type.label,
                          if (summary.vehicle.model.isNotEmpty)
                            summary.vehicle.model,
                          companion,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseMetricCard extends StatelessWidget {
  const _ExpenseMetricCard({required this.summary});

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

class _ExpenseCompositionCard extends StatelessWidget {
  const _ExpenseCompositionCard({required this.summary});

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

class _IncomeEmptyCard extends StatelessWidget {
  const _IncomeEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '收入年度统计'),
            const SizedBox(height: 18),
            Container(
              height: 118,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mutedSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '暂无收入记录',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSubtle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
