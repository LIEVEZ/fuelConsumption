import 'package:fuel_consumption/src/domain/models.dart';

abstract class AppRepository {
  Stream<List<Vehicle>> watchVehicles();

  Stream<List<EnergyRecord>> watchRecords(String vehicleId);

  Future<List<Vehicle>> getVehicles();

  Future<List<EnergyRecord>> getRecords([String? vehicleId]);

  Future<void> saveVehicle(Vehicle vehicle);

  Future<void> saveRecord(EnergyRecord record);

  Future<BackupData> exportBackup();

  Future<void> importBackup(BackupData data);
}
