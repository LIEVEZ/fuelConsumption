import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/backup/backup_data.dart';
import 'package:fuel_consumption/src/application/backup/backup_schema.dart';
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
          vehicles: [
            _vehicle(),
            _vehicle(
              id: 'vehicle-electric',
              name: '电车',
              type: VehicleType.electric,
            ),
            _vehicle(
              id: 'vehicle-hybrid',
              name: '插混',
              type: VehicleType.hybrid,
            ),
          ],
          records: [
            _fuelRecord(id: 'record-1', odometerKm: 100),
            _fuelRecord(id: 'record-2', odometerKm: 200),
            _chargeRecord(),
            _hybridRecord(),
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

  test('rejects invalid charge records', () {
    expect(
      () => validator.validate(
        _backup(
          vehicles: [
            _vehicle(
              id: 'vehicle-electric',
              name: '电车',
              type: VehicleType.electric,
            ),
          ],
          records: [_chargeRecord(kwh: 0)],
        ),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('记录 charge-1 无效: 能源数量必须大于 0'),
        ),
      ),
    );
  });

  test('rejects invalid hybrid records', () {
    expect(
      () => validator.validate(
        _backup(
          vehicles: [
            _vehicle(
              id: 'vehicle-hybrid',
              name: '插混',
              type: VehicleType.hybrid,
            ),
          ],
          records: [_hybridRecord(liters: 0, kwh: 0)],
        ),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('记录 hybrid-1 无效: 能源数量必须大于 0'),
        ),
      ),
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

Vehicle _vehicle({
  String id = 'vehicle-1',
  String name = '测试车',
  VehicleType type = VehicleType.fuel,
}) {
  return Vehicle(id: id, name: name, type: type, initialOdometerKm: 0);
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

EnergyRecord _chargeRecord({double kwh = 40}) {
  return EnergyRecord.charge(
    id: 'charge-1',
    vehicleId: 'vehicle-electric',
    date: DateTime(2026, 7, 1),
    odometerKm: 100,
    kwh: kwh,
    unitPrice: 0.6,
    chargeMode: ChargeMode.fast,
  );
}

EnergyRecord _hybridRecord({double liters = 18, double kwh = 12}) {
  return EnergyRecord.hybrid(
    id: 'hybrid-1',
    vehicleId: 'vehicle-hybrid',
    date: DateTime(2026, 7, 1),
    odometerKm: 100,
    liters: liters,
    fuelUnitPrice: 7.5,
    kwh: kwh,
    electricityUnitPrice: 0.6,
  );
}
