import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/backup_import_service.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/widgets/dialogs/import_dialog.dart';

void main() {
  testWidgets('shows backup preview before import confirmation', (
    tester,
  ) async {
    final backupJson = BackupCodec().encode(
      BackupData(
        schemaVersion: BackupCodec.currentSchemaVersion,
        exportedAt: DateTime(2026),
        vehicles: const [
          Vehicle(
            id: 'vehicle-1',
            name: '测试车',
            type: VehicleType.fuel,
            initialOdometerKm: 0,
          ),
        ],
        records: [
          EnergyRecord.fuel(
            id: 'record-1',
            vehicleId: 'vehicle-1',
            date: DateTime(2026),
            odometerKm: 100,
            liters: 10,
            unitPrice: 7,
            isFull: true,
          ),
        ],
        maintenanceRecords: [
          MaintenanceRecord(
            id: 'maintenance-1',
            vehicleId: 'vehicle-1',
            date: DateTime(2026),
            category: MaintenanceCategory.regular,
            cost: 300,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ImportDialog(actions: _FakeImportDialogActions())),
      ),
    );

    await tester.enterText(find.byType(TextField), backupJson);
    await tester.tap(find.text('解析预览'));
    await tester.pump();

    expect(find.text('导入预览'), findsOneWidget);
    expect(find.text('车辆：1 辆'), findsOneWidget);
    expect(find.text('加油/补能记录：1 条'), findsOneWidget);
    expect(find.text('保养记录：1 条'), findsOneWidget);
    expect(find.text('确认替换导入'), findsOneWidget);
    expect(find.textContaining('替换当前本地数据'), findsOneWidget);
  });
}

class _FakeImportDialogActions implements ImportDialogActions {
  @override
  Future<ImportBackupResult> importBackup(BackupData data) async {
    return const ImportBackupResult(preImportBackupJson: '{}');
  }

  @override
  Future<BackupData> parseAndValidate(String source) async {
    return BackupCodec().decode(source);
  }
}
