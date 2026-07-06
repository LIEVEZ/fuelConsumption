part of 'app_database.dart';

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
    machineAmount: Value(record.machineAmount),
    paidAmount: Value(record.paidAmount),
    discountAmount: Value(record.discountAmount),
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
  return domain.EnergyRecord.fromJson({
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
    'machineAmount': row.machineAmount,
    'paidAmount': row.paidAmount,
    'discountAmount': row.discountAmount,
    'note': row.note,
  });
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
