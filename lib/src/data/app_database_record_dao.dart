part of 'app_database.dart';

extension EnergyRecordDao on AppDatabase {
  Future<void> upsertRecord(domain.EnergyRecord record) {
    return into(
      energyRecordRows,
    ).insertOnConflictUpdate(_recordCompanion(record));
  }

  Stream<List<domain.EnergyRecord>> watchRecords(String vehicleId) {
    final query = select(energyRecordRows)
      ..where((row) => row.vehicleId.equals(vehicleId))
      ..orderBy([(row) => OrderingTerm.desc(row.date)]);
    return query.watch().map((rows) => rows.map(_recordFromRow).toList());
  }

  Future<List<domain.EnergyRecord>> getRecords([String? vehicleId]) async {
    final query = select(energyRecordRows);
    if (vehicleId != null) {
      query.where((row) => row.vehicleId.equals(vehicleId));
    }
    final rows = await query.get();
    return rows.map(_recordFromRow).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
