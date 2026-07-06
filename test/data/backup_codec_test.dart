import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
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
