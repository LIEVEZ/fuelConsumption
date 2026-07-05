import 'dart:math' as math;

import 'package:fuel_consumption/src/domain/models.dart';

class ExpenseSummary {
  const ExpenseSummary({
    required this.vehicle,
    required this.items,
    required this.annualExpenses,
    required this.energyCost,
    required this.maintenanceCost,
    required this.totalDistanceKm,
    required this.companionDays,
    required this.hasCompanionDate,
  });

  factory ExpenseSummary.from({
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
    final items = <ExpenseItem>[
      for (final record in energyRecords) ExpenseItem.energy(record),
      for (final record in maintenance) ExpenseItem.maintenance(record),
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

    return ExpenseSummary(
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
  final List<ExpenseItem> items;
  final List<AnnualExpense> annualExpenses;
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

  static List<AnnualExpense> _buildAnnualExpenses(
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
              (entry) => AnnualExpense(
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

class AnnualExpense {
  const AnnualExpense({
    required this.year,
    required this.energy,
    required this.maintenance,
  });

  final int year;
  final double energy;
  final double maintenance;

  double get total => energy + maintenance;
}

sealed class ExpenseItem {
  const ExpenseItem();

  factory ExpenseItem.energy(EnergyRecord record) = EnergyExpenseItem;

  factory ExpenseItem.maintenance(MaintenanceRecord record) =
      MaintenanceExpenseItem;

  DateTime get date;

  double get cost;
}

class EnergyExpenseItem extends ExpenseItem {
  const EnergyExpenseItem(this.record);

  final EnergyRecord record;

  @override
  DateTime get date => record.date;

  @override
  double get cost => record.totalCost;
}

class MaintenanceExpenseItem extends ExpenseItem {
  const MaintenanceExpenseItem(this.record);

  final MaintenanceRecord record;

  @override
  DateTime get date => record.date;

  @override
  double get cost => record.cost;
}

class _AnnualExpenseBuilder {
  double energy = 0;
  double maintenance = 0;
}
