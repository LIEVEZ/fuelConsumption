import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/consumption_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  test(
    'builds companion text from the earliest energy or maintenance date',
    () {
      final records = [_fuelRecord(id: 'energy-1', date: DateTime(2026, 2))];
      final maintenanceRecords = [
        MaintenanceRecord(
          id: 'maintenance-1',
          vehicleId: 'vehicle-1',
          date: DateTime(2026),
          category: MaintenanceCategory.regular,
          cost: 300,
        ),
      ];

      final text = ConsumptionStatistics.companionText(
        records: records,
        maintenanceRecords: maintenanceRecords,
        now: DateTime(2026, 4, 10),
      );

      expect(text, '爱车已相伴 0 年 3 月 9 天');
    },
  );

  test('uses empty companion text before the first cost record', () {
    final text = ConsumptionStatistics.companionText(
      records: const [],
      maintenanceRecords: const [],
      now: DateTime(2026),
    );

    expect(text, '爱车档案已建立，开始记录第一笔费用');
  });

  test('calculates average daily distance from chronological endpoints', () {
    final distance = ConsumptionStatistics.averageDailyDistance([
      _fuelRecord(id: 'energy-2', date: DateTime(2026, 1, 3), odometerKm: 320),
      _fuelRecord(id: 'energy-1', date: DateTime(2026), odometerKm: 120),
    ]);

    expect(distance, 100);
  });

  test('builds consumption trend points with the existing clamp rules', () {
    final points = ConsumptionStatistics.consumptionTrendPoints([
      _fuelRecord(id: 'energy-1', odometerKm: 100, liters: 12),
      _fuelRecord(id: 'energy-2', odometerKm: 300, liters: 20),
      _fuelRecord(id: 'energy-3', odometerKm: 290, liters: 8),
    ]);

    expect(points.map((point) => point.index), [0, 1, 2]);
    expect(points.map((point) => point.value), [8, 10, 0]);
  });

  test('keeps only the latest six monthly fuel cost buckets', () {
    final records = [
      for (var month = 1; month <= 7; month++)
        _fuelRecord(
          id: 'energy-$month',
          date: DateTime(2026, month),
          unitPrice: month.toDouble(),
        ),
    ];

    final costs = ConsumptionStatistics.monthlyFuelCosts(records);

    expect(costs.map((cost) => cost.month), [2, 3, 4, 5, 6, 7]);
    expect(costs.map((cost) => cost.cost), [20, 30, 40, 50, 60, 70]);
  });

  test('averages annual consumption by valid odometer segments', () {
    final annual = ConsumptionStatistics.annualConsumptionComparisons([
      _fuelRecord(id: 'energy-1', date: DateTime(2025, 12), odometerKm: 100),
      _fuelRecord(id: 'energy-2', date: DateTime(2026), odometerKm: 300),
      _fuelRecord(id: 'energy-3', date: DateTime(2026, 2), odometerKm: 500),
      _fuelRecord(id: 'energy-4', date: DateTime(2026, 3), odometerKm: 450),
    ]);

    expect(annual, hasLength(1));
    expect(annual.single.year, 2026);
    expect(annual.single.value, 5);
  });

  test('summarizes expense overview values', () {
    final overview = ConsumptionStatistics.expenseOverview(
      stats: const StatisticsSnapshot(
        averageConsumptionLabel: '5.00 L/100km',
        latestConsumptionLabel: '5.00 L/100km',
        totalCost: 100,
        costPerKm: 0.5,
        totalDistanceKm: 200,
      ),
      records: [
        _fuelRecord(id: 'energy-1', machineAmount: 110, paidAmount: 100),
      ],
      maintenanceRecords: [
        MaintenanceRecord(
          id: 'maintenance-1',
          vehicleId: 'vehicle-1',
          date: DateTime(2026),
          category: MaintenanceCategory.regular,
          cost: 60,
        ),
      ],
    );

    expect(overview.energyCost, 100);
    expect(overview.maintenanceCost, 60);
    expect(overview.totalExpense, 160);
    expect(overview.totalDiscount, 10);
  });
}

EnergyRecord _fuelRecord({
  required String id,
  DateTime? date,
  double odometerKm = 100,
  double liters = 10,
  double unitPrice = 7,
  String note = '',
  double? machineAmount,
  double? paidAmount,
}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: 'vehicle-1',
    date: date ?? DateTime(2026),
    odometerKm: odometerKm,
    liters: liters,
    unitPrice: unitPrice,
    isFull: true,
    machineAmount: machineAmount,
    paidAmount: paidAmount,
    note: note,
  );
}
