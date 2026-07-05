import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fuel_consumption/src/domain/models.dart' as domain;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class VehicleRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get initialOdometerKm => real()();
  TextColumn get model => text().withDefault(const Constant(''))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EnergyRecordRows extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(VehicleRows, #id)();
  DateTimeColumn get date => dateTime()();
  RealColumn get odometerKm => real()();
  TextColumn get energyType => text()();
  RealColumn get amount => real()();
  RealColumn get unitPrice => real()();
  RealColumn get totalCost => real()();
  BoolColumn get isFull => boolean().withDefault(const Constant(false))();
  RealColumn get fuelLiters => real().nullable()();
  RealColumn get kwh => real().nullable()();
  RealColumn get fuelUnitPrice => real().nullable()();
  RealColumn get electricityUnitPrice => real().nullable()();
  TextColumn get chargeMode => text().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MaintenanceRecordRows extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(VehicleRows, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  RealColumn get cost => real()();
  TextColumn get shop => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [VehicleRows, EnergyRecordRows, MaintenanceRecordRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.inMemory() : super(_openInMemoryConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _addColumnIfMissing(migrator, 'vehicle_rows', vehicleRows.model);
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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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

  Future<void> upsertRecord(domain.EnergyRecord record) {
    return into(
      energyRecordRows,
    ).insertOnConflictUpdate(_recordCompanion(record));
  }

  Future<void> upsertMaintenanceRecord(domain.MaintenanceRecord record) {
    return into(
      maintenanceRecordRows,
    ).insertOnConflictUpdate(_maintenanceRecordCompanion(record));
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

  VehicleRowsCompanion _vehicleCompanion(domain.Vehicle vehicle) {
    return VehicleRowsCompanion.insert(
      id: vehicle.id,
      name: vehicle.name,
      type: vehicle.type.name,
      initialOdometerKm: vehicle.initialOdometerKm,
      model: Value(vehicle.model),
      isDefault: Value(vehicle.isDefault),
      archived: Value(vehicle.archived),
    );
  }

  EnergyRecordRowsCompanion _recordCompanion(domain.EnergyRecord record) {
    return EnergyRecordRowsCompanion.insert(
      id: record.id,
      vehicleId: record.vehicleId,
      date: record.date,
      odometerKm: record.odometerKm,
      energyType: record.energyType.name,
      amount: record.amount,
      unitPrice: record.unitPrice,
      totalCost: record.totalCost,
      isFull: Value(record.isFull),
      fuelLiters: Value(record.fuelLiters),
      kwh: Value(record.kwh),
      fuelUnitPrice: Value(record.fuelUnitPrice),
      electricityUnitPrice: Value(record.electricityUnitPrice),
      chargeMode: Value(record.chargeMode?.name),
      note: Value(record.note),
    );
  }

  MaintenanceRecordRowsCompanion _maintenanceRecordCompanion(
    domain.MaintenanceRecord record,
  ) {
    return MaintenanceRecordRowsCompanion.insert(
      id: record.id,
      vehicleId: record.vehicleId,
      date: record.date,
      category: record.category.name,
      cost: record.cost,
      shop: Value(record.shop),
      note: Value(record.note),
    );
  }

  domain.Vehicle _vehicleFromRow(VehicleRow row) {
    return domain.Vehicle(
      id: row.id,
      name: row.name,
      type: domain.VehicleType.fromName(row.type),
      initialOdometerKm: row.initialOdometerKm,
      model: row.model,
      isDefault: row.isDefault,
      archived: row.archived,
    );
  }

  domain.EnergyRecord _recordFromRow(EnergyRecordRow row) {
    final json = <String, Object?>{
      'id': row.id,
      'vehicleId': row.vehicleId,
      'date': row.date.toIso8601String(),
      'odometerKm': row.odometerKm,
      'energyType': row.energyType,
      'amount': row.amount,
      'unitPrice': row.unitPrice,
      'totalCost': row.totalCost,
      'isFull': row.isFull,
      'fuelLiters': row.fuelLiters,
      'kwh': row.kwh,
      'fuelUnitPrice': row.fuelUnitPrice,
      'electricityUnitPrice': row.electricityUnitPrice,
      'chargeMode': row.chargeMode,
      'note': row.note,
    };
    return domain.EnergyRecord.fromJson(json);
  }

  domain.MaintenanceRecord _maintenanceRecordFromRow(MaintenanceRecordRow row) {
    return domain.MaintenanceRecord(
      id: row.id,
      vehicleId: row.vehicleId,
      date: row.date,
      category: domain.MaintenanceCategory.fromName(row.category),
      cost: row.cost,
      shop: row.shop,
      note: row.note,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, 'fuel_consumption.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

QueryExecutor _openInMemoryConnection() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return NativeDatabase.memory();
}
