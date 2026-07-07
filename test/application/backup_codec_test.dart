import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/backup/backup_codec.dart';
import 'package:fuel_consumption/src/application/backup/backup_data.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  test(
    'encodes and decodes vehicles, energy records, and maintenance records',
    () {
      final exportedAt = DateTime.utc(2026, 7, 5, 9, 30);
      final source = BackupData(
        schemaVersion: BackupCodec.currentSchemaVersion,
        exportedAt: exportedAt,
        vehicles: const [
          Vehicle(
            id: 'vehicle-1',
            name: '家用车',
            type: VehicleType.fuel,
            initialOdometerKm: 12000,
          ),
        ],
        records: [
          EnergyRecord.fuel(
            id: 'record-1',
            vehicleId: 'vehicle-1',
            date: DateTime.utc(2026, 7, 5),
            odometerKm: 12100,
            liters: 20,
            unitPrice: 7,
            isFull: true,
            machineAmount: 160,
            paidAmount: 140,
            discountAmount: 20,
            note: '95#汽油',
          ),
        ],
        maintenanceRecords: [
          MaintenanceRecord(
            id: 'maintenance-1',
            vehicleId: 'vehicle-1',
            date: DateTime.utc(2026, 7, 6),
            category: MaintenanceCategory.tire,
            cost: 688.5,
            shop: '城北汽修',
            note: '前轮两条',
          ),
        ],
      );

      final decoded = BackupCodec().decode(BackupCodec().encode(source));

      expect(decoded.schemaVersion, BackupCodec.currentSchemaVersion);
      expect(decoded.exportedAt, exportedAt);
      expect(decoded.vehicles.single.name, '家用车');
      expect(decoded.records.single.totalCost, 140);
      expect(decoded.records.single.machineAmount, 160);
      expect(decoded.records.single.paidAmount, 140);
      expect(decoded.records.single.discountAmount, 20);
      expect(
        decoded.maintenanceRecords.single.category,
        MaintenanceCategory.tire,
      );
      expect(decoded.maintenanceRecords.single.cost, 688.5);
    },
  );

  test('encodes and decodes charge and hybrid record details', () {
    final source = BackupData(
      schemaVersion: BackupCodec.currentSchemaVersion,
      exportedAt: DateTime.utc(2026, 7, 5),
      vehicles: const [
        Vehicle(
          id: 'vehicle-electric',
          name: '电车',
          type: VehicleType.electric,
          initialOdometerKm: 1000,
        ),
        Vehicle(
          id: 'vehicle-hybrid',
          name: '插混',
          type: VehicleType.hybrid,
          initialOdometerKm: 1000,
        ),
      ],
      records: [
        EnergyRecord.charge(
          id: 'charge-1',
          vehicleId: 'vehicle-electric',
          date: DateTime.utc(2026, 7, 5),
          odometerKm: 1100,
          kwh: 40,
          unitPrice: 0.6,
          chargeMode: ChargeMode.fast,
        ),
        EnergyRecord.hybrid(
          id: 'hybrid-1',
          vehicleId: 'vehicle-hybrid',
          date: DateTime.utc(2026, 7, 5),
          odometerKm: 1200,
          liters: 18,
          fuelUnitPrice: 7.5,
          kwh: 12,
          electricityUnitPrice: 0.6,
        ),
      ],
    );

    final decoded = BackupCodec().decode(BackupCodec().encode(source));
    final charge = decoded.records.first;
    final hybrid = decoded.records.last;

    expect(charge.energyType, EnergyType.charge);
    expect(charge.kwh, 40);
    expect(charge.electricityUnitPrice, 0.6);
    expect(charge.chargeMode, ChargeMode.fast);
    expect(charge.totalCost, 24);
    expect(hybrid.energyType, EnergyType.hybrid);
    expect(hybrid.fuelLiters, 18);
    expect(hybrid.fuelUnitPrice, 7.5);
    expect(hybrid.kwh, 12);
    expect(hybrid.electricityUnitPrice, 0.6);
    expect(hybrid.totalCost, closeTo(142.2, 0.001));
  });

  test('decodes old backups without maintenance records', () {
    final decoded = BackupCodec().decode('''
{
  "schemaVersion": 1,
  "exportedAt": "2026-07-05T09:30:00.000Z",
  "vehicles": [],
  "records": []
}
''');

    expect(decoded.maintenanceRecords, isEmpty);
  });

  test('decodes legacy refuel amount note into structured fields', () {
    final decoded = BackupCodec().decode('''
{
  "schemaVersion": 1,
  "exportedAt": "2026-07-05T09:30:00.000Z",
  "vehicles": [],
  "records": [
    {
      "id": "record-1",
      "vehicleId": "vehicle-1",
      "date": "2026-07-05T00:00:00.000Z",
      "odometerKm": 12100,
      "energyType": "fuel",
      "amount": 20,
      "unitPrice": 7,
      "totalCost": 140,
      "isFull": true,
      "fuelLiters": 20,
      "note": "油灯亮 · 机显金额 160.00 元 · 优惠 20.00 元 · 实付金额 140.00 元 · 92#汽油"
    }
  ]
}
''');

    final record = decoded.records.single;

    expect(record.machineAmount, 160);
    expect(record.paidAmount, 140);
    expect(record.discountAmount, 20);
    expect(record.totalCost, 140);
  });

  test('decode reports malformed json with a readable error', () {
    expect(
      () => BackupCodec().decode('not json'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('JSON 格式不正确'),
        ),
      ),
    );
  });

  test('decode reports missing required fields', () {
    expect(
      () => BackupCodec().decode('{"schemaVersion":1}'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('备份缺少字段: exportedAt'),
        ),
      ),
    );
  });

  test('decode requires object root', () {
    expect(
      () => BackupCodec().decode('[]'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('JSON 根节点必须是对象'),
        ),
      ),
    );
  });
}
