import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/record_amounts.dart';

class ConsumptionStatistics {
  const ConsumptionStatistics._();

  static String companionText({
    required List<EnergyRecord> records,
    required List<MaintenanceRecord> maintenanceRecords,
    DateTime? now,
  }) {
    final dates = <DateTime>[
      for (final record in records) record.date,
      for (final record in maintenanceRecords) record.date,
    ]..sort();
    if (dates.isEmpty) return '爱车档案已建立，开始记录第一笔费用';

    final days = (now ?? DateTime.now())
        .difference(dates.first)
        .inDays
        .clamp(0, 99999)
        .toInt();
    final years = days ~/ 365;
    final months = (days % 365) ~/ 30;
    final restDays = (days % 365) % 30;
    return '爱车已相伴 $years 年 $months 月 $restDays 天';
  }

  static ConsumptionExpenseOverview expenseOverview({
    required StatisticsSnapshot stats,
    required List<EnergyRecord> records,
    required List<MaintenanceRecord> maintenanceRecords,
  }) {
    final maintenanceCost = maintenanceRecords.fold<double>(
      0,
      (sum, record) => sum + record.cost,
    );
    return ConsumptionExpenseOverview(
      totalExpense: stats.totalCost + maintenanceCost,
      energyCost: stats.totalCost,
      maintenanceCost: maintenanceCost,
      totalDiscount: totalDiscount(records),
    );
  }

  static double totalDiscount(List<EnergyRecord> records) {
    return RecordAmounts.totalDiscount(records);
  }

  static double averageDailyDistance(List<EnergyRecord> records) {
    if (records.length < 2) return 0;
    final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first;
    final last = sorted.last;
    final days = last.date.difference(first.date).inDays.abs().clamp(1, 99999);
    return (last.odometerKm - first.odometerKm).abs() / days;
  }

  static List<ConsumptionTrendPoint> consumptionTrendPoints(
    List<EnergyRecord> records,
  ) {
    return [
      for (var index = 0; index < records.length; index++)
        ConsumptionTrendPoint(index, _consumptionValue(records, index)),
    ];
  }

  static List<MonthlyFuelCost> monthlyFuelCosts(
    List<EnergyRecord> records, {
    int limit = 6,
  }) {
    final buckets = <DateTime, double>{};
    for (final record in records) {
      final key = DateTime(record.date.year, record.date.month);
      buckets[key] = (buckets[key] ?? 0) + record.totalCost;
    }
    final entries = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .skip(entries.length > limit ? entries.length - limit : 0)
        .map((entry) => MonthlyFuelCost(entry.key.month, entry.value))
        .toList();
  }

  static List<AnnualConsumption> annualConsumptionComparisons(
    List<EnergyRecord> records,
  ) {
    final buckets = <int, List<double>>{};
    for (var index = 1; index < records.length; index++) {
      final current = records[index];
      final previous = records[index - 1];
      final distance = current.odometerKm - previous.odometerKm;
      if (distance <= 0) continue;
      final value = _energyAmount(current) / distance * 100;
      buckets.putIfAbsent(current.date.year, () => []).add(value);
    }
    final entries = buckets.entries.toList()..sort((a, b) => a.key - b.key);
    return entries
        .map(
          (entry) => AnnualConsumption(
            entry.key,
            entry.value.reduce((a, b) => a + b) / entry.value.length,
          ),
        )
        .toList();
  }

  static double _consumptionValue(List<EnergyRecord> records, int index) {
    final record = records[index];
    if (index == 0) {
      return _energyAmount(record).clamp(1, 8).toDouble();
    }
    final previous = records[index - 1];
    final distance = record.odometerKm - previous.odometerKm;
    if (distance <= 0) return 0;
    return (_energyAmount(record) / distance * 100).clamp(0, 10).toDouble();
  }

  static double _energyAmount(EnergyRecord record) {
    return record.fuelLiters ?? record.kwh ?? record.amount;
  }
}

class ConsumptionExpenseOverview {
  const ConsumptionExpenseOverview({
    required this.totalExpense,
    required this.energyCost,
    required this.maintenanceCost,
    required this.totalDiscount,
  });

  final double totalExpense;
  final double energyCost;
  final double maintenanceCost;
  final double totalDiscount;
}

class ConsumptionTrendPoint {
  const ConsumptionTrendPoint(this.index, this.value);

  final int index;
  final double value;
}

class MonthlyFuelCost {
  const MonthlyFuelCost(this.month, this.cost);

  final int month;
  final double cost;
}

class AnnualConsumption {
  const AnnualConsumption(this.year, this.value);

  final int year;
  final double value;
}
