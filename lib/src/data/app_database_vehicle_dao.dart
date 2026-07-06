part of 'app_database.dart';

extension VehicleDao on AppDatabase {
  Future<void> upsertVehicle(domain.Vehicle vehicle) {
    return transaction(() async {
      if (vehicle.isDefault) {
        await update(
          vehicleRows,
        ).write(const VehicleRowsCompanion(isDefault: Value(false)));
      }
      await into(
        vehicleRows,
      ).insertOnConflictUpdate(_vehicleCompanion(vehicle));
    });
  }

  Future<void> deleteVehicle(String vehicleId) {
    return transaction(() async {
      await (delete(
        energyRecordRows,
      )..where((row) => row.vehicleId.equals(vehicleId))).go();
      await (delete(
        maintenanceRecordRows,
      )..where((row) => row.vehicleId.equals(vehicleId))).go();
      await (delete(
        vehicleRows,
      )..where((row) => row.id.equals(vehicleId))).go();
    });
  }

  Stream<List<domain.Vehicle>> watchVehicles() {
    final query = select(vehicleRows)
      ..orderBy([(row) => OrderingTerm(expression: row.name)]);
    return query.watch().map((rows) => rows.map(_vehicleFromRow).toList());
  }

  Future<List<domain.Vehicle>> getVehicles() async {
    final rows = await select(vehicleRows).get();
    return rows.map(_vehicleFromRow).toList();
  }
}
