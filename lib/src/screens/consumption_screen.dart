import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/widgets/consumption/fuel_promo_banner.dart';
import 'package:fuel_consumption/src/widgets/consumption/hero_consumption_card.dart';
import 'package:fuel_consumption/src/widgets/consumption/home_expense_summary_card.dart';
import 'package:fuel_consumption/src/widgets/consumption/home_statistics_card.dart';
import 'package:fuel_consumption/src/widgets/consumption/vehicle_status_card.dart';
import 'package:fuel_consumption/src/widgets/consumption_charts.dart';

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
        VehicleStatusCard(
          vehicle: vehicle,
          records: records,
          maintenanceRecords: maintenanceRecords,
        ),
        const SizedBox(height: 14),
        HeroConsumptionCard(vehicle: vehicle, stats: stats),
        const SizedBox(height: 14),
        HomeExpenseSummaryCard(
          stats: stats,
          records: records,
          maintenanceRecords: maintenanceRecords,
        ),
        const SizedBox(height: 14),
        HomeStatisticsCard(stats: stats, records: records),
        const SizedBox(height: 14),
        const FuelPromoBanner(),
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
