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
  Future<List<Vehicle>> getVehicles() => _database.getVehicles();

  @override
  Future<List<EnergyRecord>> getRecords([String? vehicleId]) =>
      _database.getRecords(vehicleId);

  @override
  Future<void> saveVehicle(Vehicle vehicle) => _database.upsertVehicle(vehicle);

  @override
  Future<void> saveRecord(EnergyRecord record) =>
      _database.upsertRecord(record);

  @override
  Future<BackupData> exportBackup() async {
    return BackupData(
      schemaVersion: BackupCodec.currentSchemaVersion,
      exportedAt: DateTime.now(),
      vehicles: await getVehicles(),
      records: await getRecords(),
    );
  }

  @override
  Future<void> importBackup(BackupData data) {
    _validateBackup(data);
    return _database.replaceAll(vehicles: data.vehicles, records: data.records);
  }

  void _validateBackup(BackupData data) {
    final vehicleIds = data.vehicles.map((vehicle) => vehicle.id).toSet();
    for (final record in data.records) {
      if (!vehicleIds.contains(record.vehicleId)) {
        throw FormatException('记录引用了不存在的车辆: ${record.vehicleId}');
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
}
