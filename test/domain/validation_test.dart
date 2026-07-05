import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/validation.dart';

void main() {
  group('RecordValidator', () {
    test('rejects zero fuel amount', () {
      final record = EnergyRecord.fuel(
        id: 'record-1',
        vehicleId: 'vehicle-1',
        date: DateTime(2026),
        odometerKm: 100,
        liters: 0,
        unitPrice: 7.25,
        isFull: true,
      );

      final result = RecordValidator().validate(record, const []);

      expect(result.isValid, isFalse);
      expect(result.message, '能源数量必须大于 0');
    });

    test('rejects non-increasing odometer between records', () {
      final previous = EnergyRecord.fuel(
        id: 'record-1',
        vehicleId: 'vehicle-1',
        date: DateTime(2026),
        odometerKm: 200,
        liters: 10,
        unitPrice: 7.25,
        isFull: true,
      );
      final record = EnergyRecord.fuel(
        id: 'record-2',
        vehicleId: 'vehicle-1',
        date: DateTime(2026, 1, 2),
        odometerKm: 180,
        liters: 8,
        unitPrice: 7.25,
        isFull: true,
      );

      final result = RecordValidator().validate(record, [previous]);

      expect(result.isValid, isFalse);
      expect(result.message, '里程必须大于上一条记录');
    });
  });

  group('MaintenanceRecordValidator', () {
    test('rejects zero cost', () {
      final record = MaintenanceRecord(
        id: 'maintenance-1',
        vehicleId: 'vehicle-1',
        date: DateTime(2026),
        category: MaintenanceCategory.regular,
        cost: 0,
      );

      final result = MaintenanceRecordValidator().validate(record);

      expect(result.isValid, isFalse);
      expect(result.message, '保养费用必须大于 0');
    });
  });
}
