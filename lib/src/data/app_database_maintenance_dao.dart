part of 'app_database.dart';

extension MaintenanceRecordDao on AppDatabase {
  Future<void> upsertMaintenanceRecord(domain.MaintenanceRecord record) {
    return into(
      maintenanceRecordRows,
    ).insertOnConflictUpdate(_maintenanceRecordCompanion(record));
  }

  Stream<List<domain.MaintenanceRecord>> watchMaintenanceRecords(
    String vehicleId,
  ) {
    final query = select(maintenanceRecordRows)
      ..where((row) => row.vehicleId.equals(vehicleId))
      ..orderBy([(row) => OrderingTerm.desc(row.date)]);
    return query.watch().map(
      (rows) => rows.map(_maintenanceRecordFromRow).toList(),
    );
  }

  Future<List<domain.MaintenanceRecord>> getMaintenanceRecords([
    String? vehicleId,
  ]) async {
    final query = select(maintenanceRecordRows);
    if (vehicleId != null) {
      query.where((row) => row.vehicleId.equals(vehicleId));
    }
    final rows = await query.get();
    return rows.map(_maintenanceRecordFromRow).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
