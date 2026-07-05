import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/consumption_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/consumption_charts.dart';
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
        ConsumptionTrendCard(records: chronologicalRecords),
        const SizedBox(height: 14),
        MonthlyFuelCostCard(records: chronologicalRecords),
        const SizedBox(height: 14),
        AnnualConsumptionCard(records: chronologicalRecords),
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
    final companion = ConsumptionStatistics.companionText(
      records: records,
      maintenanceRecords: maintenanceRecords,
    );
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

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard({required this.stats, required this.records});

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
