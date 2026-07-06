part of 'app_database.dart';

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
  RealColumn get machineAmount => real().nullable()();
  RealColumn get paidAmount => real().nullable()();
  RealColumn get discountAmount => real().nullable()();
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
