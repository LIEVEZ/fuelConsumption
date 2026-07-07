import 'package:fuel_consumption/src/domain/legacy_refuel_note_parser.dart';
import 'package:fuel_consumption/src/domain/models.dart';

Map<String, Object?> vehicleToJson(Vehicle vehicle) {
  return {
    'id': vehicle.id,
    'name': vehicle.name,
    'type': vehicle.type.name,
    'initialOdometerKm': vehicle.initialOdometerKm,
    'model': vehicle.model,
    'isDefault': vehicle.isDefault,
    'archived': vehicle.archived,
  };
}

Vehicle vehicleFromJson(Map<String, Object?> json) {
  return Vehicle(
    id: json['id'] as String,
    name: json['name'] as String,
    type: VehicleType.fromName(json['type'] as String),
    initialOdometerKm: (json['initialOdometerKm'] as num).toDouble(),
    model: json['model'] as String? ?? '',
    isDefault: json['isDefault'] as bool? ?? false,
    archived: json['archived'] as bool? ?? false,
  );
}

Map<String, Object?> maintenanceRecordToJson(MaintenanceRecord record) {
  return {
    'id': record.id,
    'vehicleId': record.vehicleId,
    'date': record.date.toIso8601String(),
    'category': record.category.name,
    'cost': record.cost,
    'shop': record.shop,
    'note': record.note,
  };
}

MaintenanceRecord maintenanceRecordFromJson(Map<String, Object?> json) {
  return MaintenanceRecord(
    id: json['id'] as String,
    vehicleId: json['vehicleId'] as String,
    date: DateTime.parse(json['date'] as String),
    category: MaintenanceCategory.fromName(json['category'] as String),
    cost: (json['cost'] as num).toDouble(),
    shop: json['shop'] as String? ?? '',
    note: json['note'] as String? ?? '',
  );
}

Map<String, Object?> energyRecordToJson(EnergyRecord record) {
  return {
    'id': record.id,
    'vehicleId': record.vehicleId,
    'date': record.date.toIso8601String(),
    'odometerKm': record.odometerKm,
    'energyType': record.energyType.name,
    'amount': record.amount,
    'unitPrice': record.unitPrice,
    'totalCost': record.totalCost,
    'isFull': record.isFull,
    'fuelLiters': record.fuelLiters,
    'kwh': record.kwh,
    'fuelUnitPrice': record.fuelUnitPrice,
    'electricityUnitPrice': record.electricityUnitPrice,
    'chargeMode': record.chargeMode?.name,
    'machineAmount': record.machineAmount,
    'paidAmount': record.paidAmount,
    'discountAmount': record.discountAmount,
    'note': record.note,
  };
}

EnergyRecord energyRecordFromJson(Map<String, Object?> json) {
  final type = EnergyType.fromName(json['energyType'] as String);
  final note = json['note'] as String? ?? '';
  final legacyRefuelAmounts = LegacyRefuelNoteParser.parse(
    note,
    paidAmountFallback: (json['totalCost'] as num?)?.toDouble(),
  );
  return switch (type) {
    EnergyType.fuel => EnergyRecord.fuel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.parse(json['date'] as String),
      odometerKm: (json['odometerKm'] as num).toDouble(),
      liters: (json['fuelLiters'] as num? ?? json['amount'] as num).toDouble(),
      unitPrice: (json['fuelUnitPrice'] as num? ?? json['unitPrice'] as num)
          .toDouble(),
      isFull: json['isFull'] as bool? ?? false,
      machineAmount:
          (json['machineAmount'] as num?)?.toDouble() ??
          legacyRefuelAmounts.machineAmount,
      paidAmount:
          (json['paidAmount'] as num?)?.toDouble() ??
          legacyRefuelAmounts.paidAmount,
      discountAmount:
          (json['discountAmount'] as num?)?.toDouble() ??
          legacyRefuelAmounts.discountAmount,
      note: note,
    ),
    EnergyType.charge => EnergyRecord.charge(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.parse(json['date'] as String),
      odometerKm: (json['odometerKm'] as num).toDouble(),
      kwh: (json['kwh'] as num? ?? json['amount'] as num).toDouble(),
      unitPrice:
          (json['electricityUnitPrice'] as num? ?? json['unitPrice'] as num)
              .toDouble(),
      chargeMode: ChargeMode.fromName(
        json['chargeMode'] as String? ?? ChargeMode.slow.name,
      ),
      note: note,
    ),
    EnergyType.hybrid => EnergyRecord.hybrid(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date: DateTime.parse(json['date'] as String),
      odometerKm: (json['odometerKm'] as num).toDouble(),
      liters: (json['fuelLiters'] as num? ?? 0).toDouble(),
      fuelUnitPrice: (json['fuelUnitPrice'] as num? ?? 0).toDouble(),
      kwh: (json['kwh'] as num? ?? 0).toDouble(),
      electricityUnitPrice: (json['electricityUnitPrice'] as num? ?? 0)
          .toDouble(),
      note: note,
    ),
  };
}
