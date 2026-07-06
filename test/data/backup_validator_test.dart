import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/data/backup_schema.dart';
import 'package:fuel_consumption/src/data/backup_validator.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  const validator = BackupValidator();

  test('rejects duplicate vehicle ids', () {
    final vehicle = _vehicle();

    expect(
      () => validator.validate(_backup(vehicles: [vehicle, vehicle])),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('车辆 ID 重复'),
        ),
      ),
    );
  });

  test('rejects energy records that reference a missing vehicle', () {
    expect(
      () => validator.validate(
        _backup(records: [_fuelRecord(vehicleId: 'missing-vehicle')]),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('记录引用了不存在的车辆'),
        ),
      ),
    );
  });

  test('rejects non-increasing odometer records per vehicle', () {
    expect(
      () => validator.validate(
        _backup(
          records: [
            _fuelRecord(id: 'record-1', odometerKm: 200),
            _fuelRecord(id: 'record-2', odometerKm: 100),
          ],
        ),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('里程必须大于上一条记录'),
        ),
      ),
    );
  });

  test('accepts valid backup data', () {
    expect(
      () => validator.validate(
        _backup(
          records: [
            _fuelRecord(id: 'record-1', odometerKm: 100),
            _fuelRecord(id: 'record-2', odometerKm: 200),
          ],
          maintenanceRecords: [
            MaintenanceRecord(
              id: 'maintenance-1',
              vehicleId: 'vehicle-1',
              date: DateTime(2026, 7, 6),
              category: MaintenanceCategory.regular,
              cost: 300,
            ),
          ],
        ),
      ),
      returnsNormally,
    );
  });
}

BackupData _backup({
  List<Vehicle>? vehicles,
  List<EnergyRecord> records = const [],
  List<MaintenanceRecord> maintenanceRecords = const [],
}) {
  return BackupData(
    schemaVersion: BackupSchema.currentVersion,
    exportedAt: DateTime(2026),
    vehicles: vehicles ?? [_vehicle()],
    records: records,
    maintenanceRecords: maintenanceRecords,
  );
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
  String id = 'record-1',
  String vehicleId = 'vehicle-1',
  double odometerKm = 100,
}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: vehicleId,
    date: DateTime(2026, 7, int.parse(id.split('-').last)),
    odometerKm: odometerKm,
    liters: 10,
    unitPrice: 7,
    isFull: true,
  );
}
