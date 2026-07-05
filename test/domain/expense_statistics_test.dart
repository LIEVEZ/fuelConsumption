import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  test('summarizes energy and maintenance costs', () {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 100,
    );
    final records = [
      _energyRecord(
        id: 'energy-1',
        date: DateTime(2026),
        odometerKm: 200,
        totalCost: 70,
      ),
      _energyRecord(
        id: 'energy-2',
        date: DateTime(2026, 2),
        odometerKm: 300,
        totalCost: 140,
      ),
    ];
    final maintenanceRecords = [
      MaintenanceRecord(
        id: 'maintenance-1',
        vehicleId: vehicle.id,
        date: DateTime(2026, 3),
        category: MaintenanceCategory.regular,
        cost: 300,
      ),
    ];

    final summary = ExpenseSummary.from(
      vehicle: vehicle,
      records: records,
      maintenanceRecords: maintenanceRecords,
    );

    expect(summary.energyCost, 210);
    expect(summary.maintenanceCost, 300);
    expect(summary.totalCost, 510);
    expect(summary.totalDistanceKm, 200);
    expect(summary.costPerKm, 2.55);
    expect(summary.energyCostPerKm, 1.05);
    expect(summary.annualExpenses.single.energy, 210);
    expect(summary.annualExpenses.single.maintenance, 300);
    expect(summary.items, hasLength(3));
  });

  test('filters records by vehicle', () {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
    );

    final summary = ExpenseSummary.from(
      vehicle: vehicle,
      records: [
        _energyRecord(id: 'energy-1', vehicleId: 'vehicle-1', totalCost: 70),
        _energyRecord(id: 'energy-2', vehicleId: 'vehicle-2', totalCost: 140),
      ],
      maintenanceRecords: [
        MaintenanceRecord(
          id: 'maintenance-1',
          vehicleId: 'vehicle-2',
          date: DateTime(2026),
          category: MaintenanceCategory.regular,
          cost: 300,
        ),
      ],
    );

    expect(summary.energyCost, 70);
    expect(summary.maintenanceCost, 0);
    expect(summary.items, hasLength(1));
  });
}

EnergyRecord _energyRecord({
  required String id,
  String vehicleId = 'vehicle-1',
  DateTime? date,
  double odometerKm = 100,
  double totalCost = 70,
}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: vehicleId,
    date: date ?? DateTime(2026),
    odometerKm: odometerKm,
    liters: 10,
    unitPrice: totalCost / 10,
    isFull: true,
  );
}
