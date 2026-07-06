import 'package:fuel_consumption/src/data/app_database.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_schema.dart';
import 'package:fuel_consumption/src/data/backup_validator.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/validation.dart';

class FuelRepository implements AppRepository {
  FuelRepository(this._database, {BackupValidator? backupValidator})
    : _backupValidator = backupValidator ?? const BackupValidator();

  final AppDatabase _database;
  final BackupValidator _backupValidator;

  @override
  Stream<List<Vehicle>> watchVehicles() => _database.watchVehicles();

  @override
  Stream<List<EnergyRecord>> watchRecords(String vehicleId) =>
      _database.watchRecords(vehicleId);

  @override
  Stream<List<MaintenanceRecord>> watchMaintenanceRecords(String vehicleId) =>
      _database.watchMaintenanceRecords(vehicleId);

  @override
  Future<List<Vehicle>> getVehicles() => _database.getVehicles();

  @override
  Future<List<EnergyRecord>> getRecords([String? vehicleId]) =>
      _database.getRecords(vehicleId);

  @override
  Future<List<MaintenanceRecord>> getMaintenanceRecords([String? vehicleId]) =>
      _database.getMaintenanceRecords(vehicleId);

  @override
  Future<void> saveVehicle(Vehicle vehicle) async {
    if (vehicle.name.trim().isEmpty) {
      throw const FormatException('车辆名称不能为空');
    }
    if (vehicle.initialOdometerKm < 0) {
      throw const FormatException('初始里程不能为负数');
    }
    await _database.upsertVehicle(vehicle);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) =>
      _database.deleteVehicle(vehicleId);

  @override
  Future<void> saveRecord(EnergyRecord record) async {
    final previousRecords = (await getRecords(
      record.vehicleId,
    )).where((item) => item.id != record.id).toList();
    final result = RecordValidator().validate(record, previousRecords);
    if (!result.isValid) {
      throw FormatException(result.message);
    }
    return _database.upsertRecord(record);
  }

  @override
  Future<void> saveMaintenanceRecord(MaintenanceRecord record) async {
    final result = MaintenanceRecordValidator().validate(record);
    if (!result.isValid) {
      throw FormatException(result.message);
    }
    await _database.upsertMaintenanceRecord(record);
  }

  @override
  Future<BackupData> exportBackup() async {
    return BackupData(
      schemaVersion: BackupSchema.currentVersion,
      exportedAt: DateTime.now(),
      vehicles: await getVehicles(),
      records: await getRecords(),
      maintenanceRecords: await getMaintenanceRecords(),
    );
  }

  @override
  Future<void> validateBackup(BackupData data) async {
    _backupValidator.validate(data);
  }

  @override
  Future<void> importBackup(BackupData data) async {
    _backupValidator.validate(data);
    await _database.replaceAll(
      vehicles: data.vehicles,
      records: data.records,
      maintenanceRecords: data.maintenanceRecords,
    );
  }
}
