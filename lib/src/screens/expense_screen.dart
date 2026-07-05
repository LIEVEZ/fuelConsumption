import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
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
    final summary = _ExpenseSummary.from(
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
        _AnnualExpenseCard(years: summary.annualExpenses),
        const SizedBox(height: 14),
        _ExpenseCompositionCard(summary: summary),
        const SizedBox(height: 14),
        const _IncomeEmptyCard(),
        const SizedBox(height: 14),
        _ExpenseDetailCard(items: summary.items),
      ],
    );
  }
}

class _ExpenseSummary {
  const _ExpenseSummary({
    required this.vehicle,
    required this.items,
    required this.annualExpenses,
    required this.energyCost,
    required this.maintenanceCost,
    required this.totalDistanceKm,
    required this.companionDays,
    required this.hasCompanionDate,
  });

  factory _ExpenseSummary.from({
    required Vehicle vehicle,
    required List<EnergyRecord> records,
    required List<MaintenanceRecord> maintenanceRecords,
  }) {
    final energyRecords = records
        .where((record) => record.vehicleId == vehicle.id)
        .toList();
    final maintenance = maintenanceRecords
        .where((record) => record.vehicleId == vehicle.id)
        .toList();
    final items = <_ExpenseItem>[
      for (final record in energyRecords) _ExpenseItem.energy(record),
      for (final record in maintenance) _ExpenseItem.maintenance(record),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final energyCost = energyRecords.fold<double>(
      0,
      (sum, record) => sum + record.totalCost,
    );
    final maintenanceCost = maintenance.fold<double>(
      0,
      (sum, record) => sum + record.cost,
    );
    final companionStart = items.isEmpty ? null : items.last.date;
    final companionDays = companionStart == null
        ? 0
        : DateTime.now().difference(companionStart).inDays + 1;

    return _ExpenseSummary(
      vehicle: vehicle,
      items: items,
      annualExpenses: _buildAnnualExpenses(energyRecords, maintenance),
      energyCost: energyCost,
      maintenanceCost: maintenanceCost,
      totalDistanceKm: _totalDistance(vehicle, energyRecords),
      companionDays: companionDays,
      hasCompanionDate: companionStart != null,
    );
  }

  final Vehicle vehicle;
  final List<_ExpenseItem> items;
  final List<_AnnualExpense> annualExpenses;
  final double energyCost;
  final double maintenanceCost;
  final double totalDistanceKm;
  final int companionDays;
  final bool hasCompanionDate;

  double get totalCost => energyCost + maintenanceCost;

  double get costPerKm =>
      totalDistanceKm <= 0 ? 0 : totalCost / totalDistanceKm;

  double get energyCostPerKm =>
      totalDistanceKm <= 0 ? 0 : energyCost / totalDistanceKm;

  double get costPerDay {
    if (!hasCompanionDate || companionDays <= 0) return 0;
    return totalCost / companionDays;
  }

  static double _totalDistance(Vehicle vehicle, List<EnergyRecord> records) {
    if (records.isEmpty) return 0;
    final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
    final latestOdometer = sorted
        .map((record) => record.odometerKm)
        .reduce(math.max);
    final distanceFromInitial = latestOdometer - vehicle.initialOdometerKm;
    if (distanceFromInitial > 0) return distanceFromInitial;
    if (sorted.length < 2) return 0;
    final earliestOdometer = sorted
        .map((record) => record.odometerKm)
        .reduce(math.min);
    return math.max(0, latestOdometer - earliestOdometer);
  }

  static List<_AnnualExpense> _buildAnnualExpenses(
    List<EnergyRecord> records,
    List<MaintenanceRecord> maintenanceRecords,
  ) {
    final byYear = <int, _AnnualExpenseBuilder>{};
    for (final record in records) {
      byYear
              .putIfAbsent(record.date.year, () => _AnnualExpenseBuilder())
              .energy +=
          record.totalCost;
    }
    for (final record in maintenanceRecords) {
      byYear
              .putIfAbsent(record.date.year, () => _AnnualExpenseBuilder())
              .maintenance +=
          record.cost;
    }
    final years =
        byYear.entries
            .map(
              (entry) => _AnnualExpense(
                year: entry.key,
                energy: entry.value.energy,
                maintenance: entry.value.maintenance,
              ),
            )
            .toList()
          ..sort((a, b) => a.year.compareTo(b.year));
    return years;
  }
}

class _AnnualExpenseBuilder {
  double energy = 0;
  double maintenance = 0;
}

class _AnnualExpense {
  const _AnnualExpense({
    required this.year,
    required this.energy,
    required this.maintenance,
  });

  final int year;
  final double energy;
  final double maintenance;

  double get total => energy + maintenance;
}

sealed class _ExpenseItem {
  const _ExpenseItem();

  factory _ExpenseItem.energy(EnergyRecord record) = _EnergyExpenseItem;

  factory _ExpenseItem.maintenance(MaintenanceRecord record) =
      _MaintenanceExpenseItem;

  DateTime get date;

  double get cost;
}

class _EnergyExpenseItem extends _ExpenseItem {
  const _EnergyExpenseItem(this.record);

  final EnergyRecord record;

  @override
  DateTime get date => record.date;

  @override
  double get cost => record.totalCost;
}

class _MaintenanceExpenseItem extends _ExpenseItem {
  const _MaintenanceExpenseItem(this.record);

  final MaintenanceRecord record;

  @override
  DateTime get date => record.date;

  @override
  double get cost => record.cost;
}

class _ExpenseHeroCard extends StatelessWidget {
  const _ExpenseHeroCard({required this.summary});

  final _ExpenseSummary summary;

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

  final _ExpenseSummary summary;

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

class _AnnualExpenseCard extends StatelessWidget {
  const _AnnualExpenseCard({required this.years});

  final List<_AnnualExpense> years;

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

class _ExpenseCompositionCard extends StatelessWidget {
  const _ExpenseCompositionCard({required this.summary});

  final _ExpenseSummary summary;

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

class _ExpenseDetailCard extends StatelessWidget {
  const _ExpenseDetailCard({required this.items});

  final List<_ExpenseItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '费用明细'),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 86,
                  child: Center(child: Text('暂无费用明细')),
                ),
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _ExpenseDetailTile(item: items[index]),
                if (index != items.length - 1) const Divider(height: 1),
              ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseDetailTile extends StatelessWidget {
  const _ExpenseDetailTile({required this.item});

  final _ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      _EnergyExpenseItem(:final record) => _EnergyExpenseTile(record: record),
      _MaintenanceExpenseItem(:final record) => _MaintenanceExpenseTile(
        record: record,
      ),
    };
  }
}

class _EnergyExpenseTile extends StatelessWidget {
  const _EnergyExpenseTile({required this.record});

  final EnergyRecord record;

  @override
  Widget build(BuildContext context) {
    return _ExpenseTileLayout(
      icon: energyIcon(record.energyType),
      iconColor: energyColor(record.energyType),
      title: record.energyType.label,
      subtitle:
          '${shortDate(record.date)} ${shortTime(record.date)} · ${recordSubtitle(record)}',
      amount: record.totalCost,
    );
  }
}

class _MaintenanceExpenseTile extends StatelessWidget {
  const _MaintenanceExpenseTile({required this.record});

  final MaintenanceRecord record;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${shortDate(record.date)} ${shortTime(record.date)}',
      if (record.shop.isNotEmpty) record.shop,
      if (record.note.isNotEmpty) record.note,
    ].join(' · ');
    return _ExpenseTileLayout(
      icon: _maintenanceIcon(record.category),
      iconColor: AppColors.maintenance,
      title: '维修保养 · ${record.category.label}',
      subtitle: subtitle,
      amount: record.cost,
    );
  }
}

class _ExpenseTileLayout extends StatelessWidget {
  const _ExpenseTileLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.13),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${amount.toStringAsFixed(2)} 元',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
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

IconData _maintenanceIcon(MaintenanceCategory category) {
  return switch (category) {
    MaintenanceCategory.regular => Icons.build_circle_outlined,
    MaintenanceCategory.oil => Icons.oil_barrel_outlined,
    MaintenanceCategory.tire => Icons.album_outlined,
    MaintenanceCategory.repair => Icons.handyman_outlined,
    MaintenanceCategory.wash => Icons.local_car_wash_outlined,
    MaintenanceCategory.insurance => Icons.verified_user_outlined,
    MaintenanceCategory.other => Icons.more_horiz,
  };
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
