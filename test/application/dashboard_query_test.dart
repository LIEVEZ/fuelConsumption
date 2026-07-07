import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/dashboard_query.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  test('resolves selected vehicle by id, default, then first vehicle', () {
    const vehicles = [
      Vehicle(
        id: 'vehicle-1',
        name: '第一辆',
        type: VehicleType.fuel,
        initialOdometerKm: 0,
      ),
      Vehicle(
        id: 'vehicle-2',
        name: '默认车',
        type: VehicleType.fuel,
        initialOdometerKm: 0,
        isDefault: true,
      ),
    ];

    expect(resolveDashboardVehicle(vehicles, 'vehicle-1')?.id, 'vehicle-1');
    expect(resolveDashboardVehicle(vehicles, 'missing')?.id, 'vehicle-2');
    expect(resolveDashboardVehicle([vehicles.first], null)?.id, 'vehicle-1');
    expect(resolveDashboardVehicle(const [], null), isNull);
  });

  test('builds dashboard data with chronological records and statistics', () {
    final data = DashboardData.fromRecords(
      vehicles: [_vehicle()],
      selectedVehicle: _vehicle(),
      records: [
        _fuelRecord(
          id: 'record-2',
          date: DateTime(2026, 7, 2),
          odometerKm: 200,
        ),
        _fuelRecord(id: 'record-1', date: DateTime(2026, 7), odometerKm: 100),
      ],
      maintenanceRecords: [
        MaintenanceRecord(
          id: 'maintenance-1',
          vehicleId: 'vehicle-1',
          date: DateTime(2026, 7, 3),
          category: MaintenanceCategory.regular,
          cost: 300,
        ),
      ],
    );

    expect(data.chronologicalRecords.map((record) => record.id), [
      'record-1',
      'record-2',
    ]);
    expect(data.maintenanceRecords, hasLength(1));
    expect(data.stats.totalCost, 140);
    expect(data.stats.totalDistanceKm, 200);
  });
}

Vehicle _vehicle() {
  return const Vehicle(
    id: 'vehicle-1',
    name: '测试车',
    type: VehicleType.fuel,
    initialOdometerKm: 0,
  );
}

EnergyRecord _fuelRecord({
  required String id,
  required DateTime date,
  required double odometerKm,
}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: 'vehicle-1',
    date: date,
    odometerKm: odometerKm,
    liters: 10,
    unitPrice: 7,
    isFull: true,
  );
}
