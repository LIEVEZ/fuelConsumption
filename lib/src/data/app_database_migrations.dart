part of 'app_database.dart';

extension AppDatabaseMigrations on AppDatabase {
  MigrationStrategy buildMigrationStrategy() {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await _addColumnIfMissing(
            migrator,
            'vehicle_rows',
            vehicleRows.model,
          );
          await _addColumnIfMissing(
            migrator,
            'vehicle_rows',
            vehicleRows.isDefault,
          );
          await _addColumnIfMissing(
            migrator,
            'vehicle_rows',
            vehicleRows.archived,
          );
          await _addColumnIfMissing(
            migrator,
            'energy_record_rows',
            energyRecordRows.fuelUnitPrice,
          );
          await _addColumnIfMissing(
            migrator,
            'energy_record_rows',
            energyRecordRows.electricityUnitPrice,
          );
        }
        if (from < 3) {
          await migrator.createTable(maintenanceRecordRows);
        }
        if (from < 4) {
          await _addColumnIfMissing(
            migrator,
            'energy_record_rows',
            energyRecordRows.machineAmount,
          );
          await _addColumnIfMissing(
            migrator,
            'energy_record_rows',
            energyRecordRows.paidAmount,
          );
          await _addColumnIfMissing(
            migrator,
            'energy_record_rows',
            energyRecordRows.discountAmount,
          );
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _addColumnIfMissing(
    Migrator migrator,
    String tableName,
    GeneratedColumn column,
  ) async {
    final existingColumns = await customSelect(
      'PRAGMA table_info($tableName)',
    ).map((row) => row.read<String>('name')).get();
    if (existingColumns.contains(column.name)) {
      return;
    }
    await migrator.addColumn(switch (tableName) {
      'vehicle_rows' => vehicleRows,
      'energy_record_rows' => energyRecordRows,
      _ => throw ArgumentError.value(tableName, 'tableName'),
    }, column);
  }
}
