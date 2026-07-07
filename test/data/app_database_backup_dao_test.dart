import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/data/app_database.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  test('replaceAll rolls back when a record insert fails', () async {
    final existingVehicle = _vehicle(id: 'vehicle-existing', name: '旧车');
    final existingRecord = _fuelRecord(
      id: 'record-existing',
      vehicleId: existingVehicle.id,
    );
    await database.upsertVehicle(existingVehicle);
    await database.upsertRecord(existingRecord);

    await expectLater(
      database.replaceAll(
        vehicles: [_vehicle(id: 'vehicle-new', name: '新车')],
        records: [_fuelRecord(id: 'record-bad', vehicleId: 'missing-vehicle')],
        maintenanceRecords: const [],
      ),
      throwsA(isA<Object>()),
    );

    final vehicles = await database.getVehicles();
    final records = await database.getRecords();

    expect(vehicles, [existingVehicle]);
    expect(records, [existingRecord]);
  });
}

Vehicle _vehicle({required String id, required String name}) {
  return Vehicle(
    id: id,
    name: name,
    type: VehicleType.fuel,
    initialOdometerKm: 0,
  );
}

EnergyRecord _fuelRecord({required String id, required String vehicleId}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: vehicleId,
    date: DateTime(2026),
    odometerKm: 100,
    liters: 10,
    unitPrice: 7,
    isFull: true,
  );
}
