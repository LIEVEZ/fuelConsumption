part of 'app_database.dart';

extension BackupDao on AppDatabase {
  Future<void> replaceAll({
    required List<domain.Vehicle> vehicles,
    required List<domain.EnergyRecord> records,
    required List<domain.MaintenanceRecord> maintenanceRecords,
  }) async {
    await transaction(() async {
      await delete(maintenanceRecordRows).go();
      await delete(energyRecordRows).go();
      await delete(vehicleRows).go();
      for (final vehicle in vehicles) {
        await upsertVehicle(vehicle);
      }
      for (final record in records) {
        await upsertRecord(record);
      }
      for (final record in maintenanceRecords) {
        await upsertMaintenanceRecord(record);
      }
    });
  }
}
