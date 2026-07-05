import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class ConsumptionScreen extends StatelessWidget {
  const ConsumptionScreen({
    required this.vehicle,
    required this.records,
    required this.chronologicalRecords,
    required this.maintenanceRecords,
    required this.stats,
    super.key,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final List<EnergyRecord> chronologicalRecords;
  final List<MaintenanceRecord> maintenanceRecords;
  final StatisticsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      children: [
        _VehicleStatusCard(
          vehicle: vehicle,
          records: records,
          maintenanceRecords: maintenanceRecords,
        ),
        const SizedBox(height: 14),
        _HeroConsumptionCard(vehicle: vehicle, stats: stats),
        const SizedBox(height: 14),
        _HomeExpenseSummaryCard(
          stats: stats,
          records: records,
          maintenanceRecords: maintenanceRecords,
        ),
        const SizedBox(height: 14),
        _StatisticsCard(stats: stats, records: records),
        const SizedBox(height: 14),
        const _FuelPromoBanner(),
        const SizedBox(height: 14),
        _ConsumptionTrendCard(records: chronologicalRecords),
        const SizedBox(height: 14),
        _MonthlyFuelCostCard(records: chronologicalRecords),
        const SizedBox(height: 14),
        _AnnualConsumptionCard(records: chronologicalRecords),
      ],
    );
  }
}

class _VehicleStatusCard extends StatelessWidget {
  const _VehicleStatusCard({
    required this.vehicle,
    required this.records,
    required this.maintenanceRecords,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;

  @override
  Widget build(BuildContext context) {
    final companion = _companionText(records, maintenanceRecords);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '今日适合记录用车',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  vehicle.type.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(vehicleIcon(vehicle.type), color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      companion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _companionText(
    List<EnergyRecord> records,
    List<MaintenanceRecord> maintenanceRecords,
  ) {
    final dates = <DateTime>[
      for (final record in records) record.date,
      for (final record in maintenanceRecords) record.date,
    ]..sort();
    if (dates.isEmpty) return '爱车档案已建立，开始记录第一笔费用';
    final days = DateTime.now().difference(dates.first).inDays.clamp(0, 99999);
    final years = days ~/ 365;
    final months = (days % 365) ~/ 30;
    final restDays = (days % 365) % 30;
    return '爱车已相伴 $years 年 $months 月 $restDays 天';
  }
}

class _HeroConsumptionCard extends StatelessWidget {
  const _HeroConsumptionCard({required this.vehicle, required this.stats});

  final Vehicle vehicle;
  final StatisticsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    final latest = parseLeadingNumber(stats.latestConsumptionLabel);
    final display = latest == null || latest == 0
        ? parseLeadingNumber(stats.averageConsumptionLabel)
        : latest;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -10,
            child: Container(
              width: 180,
              height: 116,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(72),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '最新油耗',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSubtle,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        vehicle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (display ?? 0).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _unitForVehicle(vehicle),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (var index = 0; index < 5; index++)
                      Icon(
                        Icons.star,
                        color: index < 3 ? AppColors.warning : AppColors.border,
                        size: 28,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _unitForVehicle(Vehicle vehicle) {
    return switch (vehicle.type) {
      VehicleType.electric => 'kWh/百公里',
      VehicleType.hybrid => '综合/百公里',
      VehicleType.fuel || VehicleType.motorcycle => '升/百公里',
    };
  }
}

class _HomeExpenseSummaryCard extends StatelessWidget {
  const _HomeExpenseSummaryCard({
    required this.stats,
    required this.records,
    required this.maintenanceRecords,
  });

  final StatisticsSnapshot stats;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;

  @override
  Widget build(BuildContext context) {
    final maintenanceCost = maintenanceRecords.fold<double>(
      0,
      (sum, record) => sum + record.cost,
    );
    final totalExpense = stats.totalCost + maintenanceCost;
    final discount = _totalDiscount(records);
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
                    value: totalExpense.toStringAsFixed(2),
                    unit: '元',
                    color: AppColors.text,
                  ),
                ),
                Expanded(
                  child: _ExpenseMetric(
                    label: '油费总计',
                    value: stats.totalCost.toStringAsFixed(2),
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
                    value: maintenanceCost.toStringAsFixed(2),
                    unit: '元',
                    color: AppColors.maintenance,
                  ),
                ),
                Expanded(
                  child: _ExpenseMetric(
                    label: '总计优惠',
                    value: discount.toStringAsFixed(2),
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

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard({required this.stats, required this.records});

  final StatisticsSnapshot stats;
  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final latestDistance = _latestDailyDistance(records);
    final totalDiscount = _totalDiscount(records);
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

  double _latestDailyDistance(List<EnergyRecord> records) {
    if (records.length < 2) return 0;
    final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first;
    final last = sorted.last;
    final days = last.date.difference(first.date).inDays.abs().clamp(1, 99999);
    return (last.odometerKm - first.odometerKm).abs() / days;
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

class _FuelPromoBanner extends StatelessWidget {
  const _FuelPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.skySoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.skyDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '优惠加油',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.skyDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '记录机显金额、实付金额和优惠，首页自动汇总节省金额',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
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

class _ConsumptionTrendCard extends StatelessWidget {
  const _ConsumptionTrendCard({required this.records});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var index = 0; index < records.length; index++) {
      final value = _consumptionValue(index);
      spots.add(FlSpot(index.toDouble(), value));
    }

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

  double _consumptionValue(int index) {
    final record = records[index];
    if (index == 0) {
      return (record.fuelLiters ?? record.kwh ?? record.amount).clamp(1, 8);
    }
    final previous = records[index - 1];
    final distance = record.odometerKm - previous.odometerKm;
    if (distance <= 0) return 0;
    return ((record.fuelLiters ?? record.kwh ?? record.amount) / distance * 100)
        .clamp(0, 10)
        .toDouble();
  }
}

class _MonthlyFuelCostCard extends StatelessWidget {
  const _MonthlyFuelCostCard({required this.records});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final entries = _monthlyCosts(records);
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

  List<_MonthCost> _monthlyCosts(List<EnergyRecord> records) {
    final buckets = <DateTime, double>{};
    for (final record in records) {
      final key = DateTime(record.date.year, record.date.month);
      buckets[key] = (buckets[key] ?? 0) + record.totalCost;
    }
    final entries = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .skip(entries.length > 6 ? entries.length - 6 : 0)
        .map((entry) => _MonthCost(entry.key.month, entry.value))
        .toList();
  }
}

class _AnnualConsumptionCard extends StatelessWidget {
  const _AnnualConsumptionCard({required this.records});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final entries = _annualConsumption(records);
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

  List<_YearConsumption> _annualConsumption(List<EnergyRecord> records) {
    final buckets = <int, List<double>>{};
    for (var index = 1; index < records.length; index++) {
      final current = records[index];
      final previous = records[index - 1];
      final distance = current.odometerKm - previous.odometerKm;
      if (distance <= 0) continue;
      final amount = current.fuelLiters ?? current.kwh ?? current.amount;
      final value = amount / distance * 100;
      buckets.putIfAbsent(current.date.year, () => []).add(value);
    }
    final entries = buckets.entries.toList()..sort((a, b) => a.key - b.key);
    return entries
        .map(
          (entry) => _YearConsumption(
            entry.key,
            entry.value.reduce((a, b) => a + b) / entry.value.length,
          ),
        )
        .toList();
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

class _MonthCost {
  const _MonthCost(this.month, this.cost);

  final int month;
  final double cost;
}

class _YearConsumption {
  const _YearConsumption(this.year, this.value);

  final int year;
  final double value;
}

double _totalDiscount(List<EnergyRecord> records) {
  return records.fold<double>(0, (sum, record) {
    return sum + _discountFromRecord(record);
  });
}

double _discountFromRecord(EnergyRecord record) {
  final explicitDiscount = _numberAfterLabel(record.note, '优惠');
  if (explicitDiscount != null) {
    return explicitDiscount;
  }

  final machineAmount = _numberAfterLabel(record.note, '机显金额');
  final paidAmount = _numberAfterLabel(record.note, '实付金额');
  if (machineAmount != null && paidAmount != null) {
    return (machineAmount - paidAmount).clamp(0, double.infinity).toDouble();
  }

  return 0;
}

double? _numberAfterLabel(String text, String label) {
  final pattern = RegExp('$label\\s*([0-9]+(?:\\.[0-9]+)?)');
  final match = pattern.firstMatch(text);
  if (match == null) return null;
  return double.tryParse(match.group(1)!);
}
