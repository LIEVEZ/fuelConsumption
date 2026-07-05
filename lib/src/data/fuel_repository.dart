import 'package:fuel_consumption/src/data/app_database.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/validation.dart';

class FuelRepository implements AppRepository {
  FuelRepository(this._database);

  final AppDatabase _database;

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
      schemaVersion: BackupCodec.currentSchemaVersion,
      exportedAt: DateTime.now(),
      vehicles: await getVehicles(),
      records: await getRecords(),
      maintenanceRecords: await getMaintenanceRecords(),
    );
  }

  @override
  Future<void> validateBackup(BackupData data) async {
    _validateBackup(data);
  }

  @override
  Future<void> importBackup(BackupData data) async {
    _validateBackup(data);
    await _database.replaceAll(
      vehicles: data.vehicles,
      records: data.records,
      maintenanceRecords: data.maintenanceRecords,
    );
  }

  void _validateBackup(BackupData data) {
    _ensureUnique('车辆', data.vehicles.map((vehicle) => vehicle.id));
    _ensureUnique('补能记录', data.records.map((record) => record.id));
    _ensureUnique('保养记录', data.maintenanceRecords.map((record) => record.id));

    final vehicleIds = data.vehicles.map((vehicle) => vehicle.id).toSet();
    for (final vehicle in data.vehicles) {
      if (vehicle.name.trim().isEmpty) {
        throw FormatException('车辆 ${vehicle.id} 名称不能为空');
      }
      if (vehicle.initialOdometerKm < 0) {
        throw FormatException('车辆 ${vehicle.id} 初始里程不能为负数');
      }
    }

    for (final record in data.records) {
      if (!vehicleIds.contains(record.vehicleId)) {
        throw FormatException('记录引用了不存在的车辆: ${record.vehicleId}');
      }
    }
    for (final record in data.maintenanceRecords) {
      if (!vehicleIds.contains(record.vehicleId)) {
        throw FormatException('保养记录引用了不存在的车辆: ${record.vehicleId}');
      }
      final result = MaintenanceRecordValidator().validate(record);
      if (!result.isValid) {
        throw FormatException('保养记录 ${record.id} 无效: ${result.message}');
      }
    }

    final validator = RecordValidator();
    for (final vehicle in data.vehicles) {
      final records =
          data.records
              .where((record) => record.vehicleId == vehicle.id)
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      final accepted = <EnergyRecord>[];
      for (final record in records) {
        final result = validator.validate(record, accepted);
        if (!result.isValid) {
          throw FormatException('记录 ${record.id} 无效: ${result.message}');
        }
        accepted.add(record);
      }
    }
  }

  void _ensureUnique(String label, Iterable<String> ids) {
    final seen = <String>{};
    for (final id in ids) {
      if (id.trim().isEmpty) {
        throw FormatException('$label ID 不能为空');
      }
      if (!seen.add(id)) {
        throw FormatException('$label ID 重复: $id');
      }
    }
  }
}
