import 'package:drift/drift.dart';
import 'package:fuel_consumption/src/data/app_database_connection.dart';
import 'package:fuel_consumption/src/domain/models.dart' as domain;

part 'app_database.g.dart';
part 'app_database_backup_dao.dart';
part 'app_database_maintenance_dao.dart';
part 'app_database_mappers.dart';
part 'app_database_migrations.dart';
part 'app_database_record_dao.dart';
part 'app_database_tables.dart';
part 'app_database_vehicle_dao.dart';

@DriftDatabase(tables: [VehicleRows, EnergyRecordRows, MaintenanceRecordRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  AppDatabase.inMemory() : super(openInMemoryDatabaseConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => buildMigrationStrategy();
}
