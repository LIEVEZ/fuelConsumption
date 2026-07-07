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
  final type = domain.EnergyType.fromName(row.energyType);
  return switch (type) {
    domain.EnergyType.fuel => _fuelRecordFromRow(row),
    domain.EnergyType.charge => domain.EnergyRecord.charge(
      id: row.id,
      vehicleId: row.vehicleId,
      date: row.date,
      odometerKm: row.odometerKm,
      kwh: row.kwh ?? row.amount,
      unitPrice: row.electricityUnitPrice ?? row.unitPrice,
      chargeMode: domain.ChargeMode.fromName(
        row.chargeMode ?? domain.ChargeMode.slow.name,
      ),
      note: row.note,
    ),
    domain.EnergyType.hybrid => domain.EnergyRecord.hybrid(
      id: row.id,
      vehicleId: row.vehicleId,
      date: row.date,
      odometerKm: row.odometerKm,
      liters: row.fuelLiters ?? 0,
      fuelUnitPrice: row.fuelUnitPrice ?? 0,
      kwh: row.kwh ?? 0,
      electricityUnitPrice: row.electricityUnitPrice ?? 0,
      note: row.note,
    ),
  };
}

domain.EnergyRecord _fuelRecordFromRow(EnergyRecordRow row) {
  final legacyRefuelAmounts = LegacyRefuelNoteParser.parse(
    row.note,
    paidAmountFallback: row.totalCost,
  );
  return domain.EnergyRecord.fuel(
    id: row.id,
    vehicleId: row.vehicleId,
    date: row.date,
    odometerKm: row.odometerKm,
    liters: row.fuelLiters ?? row.amount,
    unitPrice: row.fuelUnitPrice ?? row.unitPrice,
    isFull: row.isFull,
    machineAmount: row.machineAmount ?? legacyRefuelAmounts.machineAmount,
    paidAmount: row.paidAmount ?? legacyRefuelAmounts.paidAmount,
    discountAmount: row.discountAmount ?? legacyRefuelAmounts.discountAmount,
    note: row.note,
  );
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
