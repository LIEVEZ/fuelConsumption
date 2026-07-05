import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/data/app_database.dart';
import 'package:fuel_consumption/src/data/fuel_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  late AppDatabase database;
  late FuelRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = FuelRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saveRecord validates through repository', () async {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
      isDefault: true,
    );
    await repository.saveVehicle(vehicle);

    final record = EnergyRecord.fuel(
      id: 'record-1',
      vehicleId: vehicle.id,
      date: DateTime(2026),
      odometerKm: 100,
      liters: 0,
      unitPrice: 7.25,
      isFull: true,
    );

    await expectLater(
      repository.saveRecord(record),
      throwsA(isA<FormatException>()),
    );
  });

  test('saveMaintenanceRecord validates through repository', () async {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
      isDefault: true,
    );
    await repository.saveVehicle(vehicle);

    final record = MaintenanceRecord(
      id: 'maintenance-1',
      vehicleId: vehicle.id,
      date: DateTime(2026),
      category: MaintenanceCategory.regular,
      cost: 0,
    );

    await expectLater(
      repository.saveMaintenanceRecord(record),
      throwsA(isA<FormatException>()),
    );
  });

  test('validateBackup rejects duplicate record ids', () async {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
    );
    final record = EnergyRecord.fuel(
      id: 'record-1',
      vehicleId: vehicle.id,
      date: DateTime(2026),
      odometerKm: 100,
      liters: 10,
      unitPrice: 7,
      isFull: true,
    );

    await expectLater(
      repository.validateBackup(
        BackupData(
          schemaVersion: 1,
          exportedAt: DateTime(2026),
          vehicles: [vehicle],
          records: [record, record],
        ),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('补能记录 ID 重复'),
        ),
      ),
    );
  });
}
