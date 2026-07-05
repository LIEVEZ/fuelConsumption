import 'package:fuel_consumption/src/domain/models.dart';

abstract class AppRepository {
  Stream<List<Vehicle>> watchVehicles();

  Stream<List<EnergyRecord>> watchRecords(String vehicleId);

  Stream<List<MaintenanceRecord>> watchMaintenanceRecords(String vehicleId);

  Future<List<Vehicle>> getVehicles();

  Future<List<EnergyRecord>> getRecords([String? vehicleId]);

  Future<List<MaintenanceRecord>> getMaintenanceRecords([String? vehicleId]);

  Future<void> saveVehicle(Vehicle vehicle);

  Future<void> deleteVehicle(String vehicleId);

  Future<void> saveRecord(EnergyRecord record);

  Future<void> saveMaintenanceRecord(MaintenanceRecord record);

  Future<BackupData> exportBackup();

  Future<void> validateBackup(BackupData data);

  Future<void> importBackup(BackupData data);
}
