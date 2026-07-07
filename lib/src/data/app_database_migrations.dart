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
          await _backfillLegacyRefuelAmountColumns();
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

  Future<void> _backfillLegacyRefuelAmountColumns() async {
    final rows = await customSelect(
      '''
      SELECT id, note, total_cost, machine_amount, paid_amount, discount_amount
      FROM energy_record_rows
      WHERE energy_type = ? AND note <> ''
      ''',
      variables: [Variable.withString(domain.EnergyType.fuel.name)],
      readsFrom: {energyRecordRows},
    ).get();

    for (final row in rows) {
      final parsed = LegacyRefuelNoteParser.parse(
        row.read<String>('note'),
        paidAmountFallback: row.read<double>('total_cost'),
      );
      if (!parsed.hasAny) {
        continue;
      }

      final machineAmount = row.readNullable<double>('machine_amount');
      final paidAmount = row.readNullable<double>('paid_amount');
      final discountAmount = row.readNullable<double>('discount_amount');
      final companion = EnergyRecordRowsCompanion(
        machineAmount: machineAmount == null && parsed.machineAmount != null
            ? Value(parsed.machineAmount)
            : const Value.absent(),
        paidAmount: paidAmount == null && parsed.paidAmount != null
            ? Value(parsed.paidAmount)
            : const Value.absent(),
        discountAmount: discountAmount == null && parsed.discountAmount != null
            ? Value(parsed.discountAmount)
            : const Value.absent(),
      );
      if (!companion.machineAmount.present &&
          !companion.paidAmount.present &&
          !companion.discountAmount.present) {
        continue;
      }

      await (update(energyRecordRows)
            ..where((table) => table.id.equals(row.read<String>('id'))))
          .write(companion);
    }
  }
}
