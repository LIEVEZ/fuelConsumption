import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/backup/backup_codec.dart';
import 'package:fuel_consumption/src/application/backup/backup_data.dart';
import 'package:fuel_consumption/src/application/dashboard_commands.dart';
import 'package:fuel_consumption/src/application/ports/app_repository.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/application/vehicle_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  test(
    'delegates vehicle and record commands through the repository',
    () async {
      final repository = _FakeCommandRepository();
      final commands = DashboardCommandService(repository: repository);

      await commands.createVehicle(
        const VehicleDraft(
          name: '家庭车',
          type: VehicleType.fuel,
          initialOdometerKm: 1000,
          model: 'SUV',
        ),
      );
      final fuelRecord = await commands.saveRefuelRecord(_refuelInput());
      final maintenanceRecord = await commands.saveMaintenanceRecord(
        _maintenanceInput(),
      );
      await commands.deleteVehicle('old-vehicle');

      expect(repository.savedVehicles.single.name, '家庭车');
      expect(repository.savedVehicles.single.id, isNotEmpty);
      expect(repository.savedRecords.single, fuelRecord);
      expect(fuelRecord.id, isNotEmpty);
      expect(fuelRecord.vehicleId, 'vehicle-1');
      expect(fuelRecord.odometerKm, 1100);
      expect(fuelRecord.fuelLiters, 20);
      expect(fuelRecord.machineAmount, 160);
      expect(fuelRecord.discountAmount, 20);
      expect(fuelRecord.paidAmount, 140);
      expect(repository.savedMaintenanceRecords.single, maintenanceRecord);
      expect(maintenanceRecord.id, isNotEmpty);
      expect(maintenanceRecord.category, MaintenanceCategory.regular);
      expect(maintenanceRecord.cost, 200);
      expect(repository.deletedVehicleIds, ['old-vehicle']);
    },
  );

  test('saves charge and hybrid inputs as energy records', () async {
    final repository = _FakeCommandRepository();
    final commands = DashboardCommandService(repository: repository);

    final chargeRecord = await commands.saveChargeRecord(_chargeInput());
    final hybridRecord = await commands.saveHybridRecord(_hybridInput());

    expect(repository.savedRecords, [chargeRecord, hybridRecord]);
    expect(chargeRecord.energyType, EnergyType.charge);
    expect(chargeRecord.kwh, 42);
    expect(chargeRecord.electricityUnitPrice, 0.68);
    expect(chargeRecord.chargeMode, ChargeMode.fast);
    expect(hybridRecord.energyType, EnergyType.hybrid);
    expect(hybridRecord.fuelLiters, 18);
    expect(hybridRecord.kwh, 12);
    expect(hybridRecord.totalCost, closeTo(142.2, 0.001));
  });

  test('rejects invalid record command inputs', () async {
    final repository = _FakeCommandRepository(
      backup: BackupData(
        schemaVersion: 1,
        exportedAt: DateTime(2026),
        vehicles: [_vehicle()],
        records: [
          _fuelRecordWith(
            id: 'previous',
            date: DateTime(2026, 7),
            odometerKm: 1200,
          ),
        ],
      ),
    );
    final commands = DashboardCommandService(repository: repository);

    await expectLater(
      commands.saveChargeRecord(_chargeInput(kwhText: '0')),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          '请填写有效充电电量',
        ),
      ),
    );
    await expectLater(
      commands.saveHybridRecord(_hybridInput(litersText: '0', kwhText: '0')),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          '请至少填写燃油或电量',
        ),
      ),
    );
    await expectLater(
      commands.saveMaintenanceRecord(_maintenanceInput(costText: '0')),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          '请填写有效保养费用',
        ),
      ),
    );
    await expectLater(
      commands.saveRefuelRecord(
        _refuelInput(date: DateTime(2026, 7, 2), odometerText: '1190'),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          '里程必须大于上一条记录',
        ),
      ),
    );
    expect(repository.savedRecords, isEmpty);
    expect(repository.savedMaintenanceRecords, isEmpty);
  });

  test('exports and imports backup json through dialog actions', () async {
    final repository = _FakeCommandRepository(
      backup: BackupData(
        schemaVersion: 1,
        exportedAt: DateTime(2026),
        vehicles: [_vehicle()],
        records: [_fuelRecord()],
      ),
    );
    final commands = DashboardCommandService(repository: repository);
    final exportedJson = await commands.exportBackupJson();
    final decoded = BackupCodec().decode(exportedJson);

    expect(decoded.vehicles.single.id, 'vehicle-1');
    expect(decoded.records.single.id, 'record-1');

    final actions = commands.importActions;
    final parsed = await actions.parseAndValidate(exportedJson);
    final result = await actions.importBackup(parsed);

    expect(repository.validatedBackups.single.vehicles.single.id, 'vehicle-1');
    expect(repository.importedBackups.single.records.single.id, 'record-1');
    expect(result.preImportBackupJson, exportedJson);
  });
}

class _FakeCommandRepository implements AppRepository {
  _FakeCommandRepository({BackupData? backup})
    : backup =
          backup ??
          BackupData(
            schemaVersion: 1,
            exportedAt: DateTime(2026),
            vehicles: [_vehicle()],
            records: const [],
          );

  BackupData backup;
  final savedVehicles = <Vehicle>[];
  final savedRecords = <EnergyRecord>[];
  final savedMaintenanceRecords = <MaintenanceRecord>[];
  final deletedVehicleIds = <String>[];
  final validatedBackups = <BackupData>[];
  final importedBackups = <BackupData>[];

  @override
  Stream<List<Vehicle>> watchVehicles() => Stream.value(backup.vehicles);

  @override
  Stream<List<EnergyRecord>> watchRecords(String vehicleId) {
    return Stream.value(backup.records);
  }

  @override
  Stream<List<MaintenanceRecord>> watchMaintenanceRecords(String vehicleId) {
    return Stream.value(backup.maintenanceRecords);
  }

  @override
  Future<List<Vehicle>> getVehicles() async => backup.vehicles;

  @override
  Future<List<EnergyRecord>> getRecords([String? vehicleId]) async {
    return backup.records;
  }

  @override
  Future<List<MaintenanceRecord>> getMaintenanceRecords([
    String? vehicleId,
  ]) async {
    return backup.maintenanceRecords;
  }

  @override
  Future<void> saveVehicle(Vehicle vehicle) async {
    savedVehicles.add(vehicle);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    deletedVehicleIds.add(vehicleId);
  }

  @override
  Future<void> saveRecord(EnergyRecord record) async {
    savedRecords.add(record);
  }

  @override
  Future<void> saveMaintenanceRecord(MaintenanceRecord record) async {
    savedMaintenanceRecords.add(record);
  }

  @override
  Future<BackupData> exportBackup() async => backup;

  @override
  Future<void> validateBackup(BackupData data) async {
    validatedBackups.add(data);
  }

  @override
  Future<void> importBackup(BackupData data) async {
    importedBackups.add(data);
    backup = data;
  }
}

Vehicle _vehicle() {
  return const Vehicle(
    id: 'vehicle-1',
    name: '家庭车',
    type: VehicleType.fuel,
    initialOdometerKm: 1000,
  );
}

EnergyRecord _fuelRecord() {
  return _fuelRecordWith();
}

EnergyRecord _fuelRecordWith({
  String id = 'record-1',
  DateTime? date,
  double odometerKm = 1100,
}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: 'vehicle-1',
    date: date ?? DateTime(2026, 7),
    odometerKm: odometerKm,
    liters: 20,
    unitPrice: 7,
    isFull: true,
  );
}

RefuelRecordInput _refuelInput({DateTime? date, String odometerText = '1100'}) {
  return RefuelRecordInput(
    vehicleId: 'vehicle-1',
    date: date ?? DateTime(2026, 7),
    odometerText: odometerText,
    unitPriceText: '8',
    litersText: '20',
    machineAmountText: '160',
    paidUnitPriceText: '7',
    discountText: '20',
    paidAmountText: '140',
    isFull: true,
    warningLightOn: false,
    fuelGrade: '92#汽油',
    noteText: '',
  );
}

ChargeRecordInput _chargeInput({String kwhText = '42'}) {
  return ChargeRecordInput(
    vehicleId: 'vehicle-1',
    date: DateTime(2026, 7, 2),
    odometerText: '1200',
    kwhText: kwhText,
    unitPriceText: '0.68',
    chargeMode: ChargeMode.fast,
    noteText: '商场快充',
  );
}

HybridRecordInput _hybridInput({
  String litersText = '18',
  String kwhText = '12',
}) {
  return HybridRecordInput(
    vehicleId: 'vehicle-1',
    date: DateTime(2026, 7, 3),
    odometerText: '1300',
    litersText: litersText,
    fuelUnitPriceText: '7.5',
    kwhText: kwhText,
    electricityUnitPriceText: '0.6',
    noteText: '周末长途',
  );
}

MaintenanceRecordInput _maintenanceInput({String costText = '200'}) {
  return MaintenanceRecordInput(
    vehicleId: 'vehicle-1',
    date: DateTime(2026, 7, 2),
    category: MaintenanceCategory.regular,
    costText: costText,
    shopText: '',
    noteText: '',
  );
}
