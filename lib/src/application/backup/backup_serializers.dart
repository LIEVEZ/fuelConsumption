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

Vehicle vehicleFromJson(Map<String, Object?> json, String path) {
  return Vehicle(
    id: _requiredString(json, path, 'id'),
    name: _requiredString(json, path, 'name'),
    type: _enumValue(json, path, 'type', VehicleType.fromName),
    initialOdometerKm: _requiredNumber(json, path, 'initialOdometerKm'),
    model: _optionalString(json, path, 'model') ?? '',
    isDefault: _optionalBool(json, path, 'isDefault') ?? false,
    archived: _optionalBool(json, path, 'archived') ?? false,
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

MaintenanceRecord maintenanceRecordFromJson(
  Map<String, Object?> json,
  String path,
) {
  return MaintenanceRecord(
    id: _requiredString(json, path, 'id'),
    vehicleId: _requiredString(json, path, 'vehicleId'),
    date: _requiredDateTime(json, path, 'date'),
    category: _enumValue(json, path, 'category', _maintenanceCategoryFromName),
    cost: _requiredNumber(json, path, 'cost'),
    shop: _optionalString(json, path, 'shop') ?? '',
    note: _optionalString(json, path, 'note') ?? '',
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

EnergyRecord energyRecordFromJson(Map<String, Object?> json, String path) {
  final type = _enumValue(json, path, 'energyType', EnergyType.fromName);
  final note = _optionalString(json, path, 'note') ?? '';
  final legacyRefuelAmounts = LegacyRefuelNoteParser.parse(
    note,
    paidAmountFallback: _optionalNumber(json, path, 'totalCost'),
  );
  return switch (type) {
    EnergyType.fuel => EnergyRecord.fuel(
      id: _requiredString(json, path, 'id'),
      vehicleId: _requiredString(json, path, 'vehicleId'),
      date: _requiredDateTime(json, path, 'date'),
      odometerKm: _requiredNumber(json, path, 'odometerKm'),
      liters:
          _optionalNumber(json, path, 'fuelLiters') ??
          _requiredNumber(json, path, 'amount'),
      unitPrice:
          _optionalNumber(json, path, 'fuelUnitPrice') ??
          _requiredNumber(json, path, 'unitPrice'),
      isFull: _optionalBool(json, path, 'isFull') ?? false,
      machineAmount:
          _optionalNumber(json, path, 'machineAmount') ??
          legacyRefuelAmounts.machineAmount,
      paidAmount:
          _optionalNumber(json, path, 'paidAmount') ??
          legacyRefuelAmounts.paidAmount,
      discountAmount:
          _optionalNumber(json, path, 'discountAmount') ??
          legacyRefuelAmounts.discountAmount,
      note: note,
    ),
    EnergyType.charge => EnergyRecord.charge(
      id: _requiredString(json, path, 'id'),
      vehicleId: _requiredString(json, path, 'vehicleId'),
      date: _requiredDateTime(json, path, 'date'),
      odometerKm: _requiredNumber(json, path, 'odometerKm'),
      kwh:
          _optionalNumber(json, path, 'kwh') ??
          _requiredNumber(json, path, 'amount'),
      unitPrice:
          _optionalNumber(json, path, 'electricityUnitPrice') ??
          _requiredNumber(json, path, 'unitPrice'),
      chargeMode:
          _optionalEnumValue(json, path, 'chargeMode', ChargeMode.fromName) ??
          ChargeMode.slow,
      note: note,
    ),
    EnergyType.hybrid => EnergyRecord.hybrid(
      id: _requiredString(json, path, 'id'),
      vehicleId: _requiredString(json, path, 'vehicleId'),
      date: _requiredDateTime(json, path, 'date'),
      odometerKm: _requiredNumber(json, path, 'odometerKm'),
      liters: _optionalNumber(json, path, 'fuelLiters') ?? 0,
      fuelUnitPrice: _optionalNumber(json, path, 'fuelUnitPrice') ?? 0,
      kwh: _optionalNumber(json, path, 'kwh') ?? 0,
      electricityUnitPrice:
          _optionalNumber(json, path, 'electricityUnitPrice') ?? 0,
      note: note,
    ),
  };
}

String _requiredString(Map<String, Object?> json, String path, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('$path.$key 必须是字符串');
}

String? _optionalString(Map<String, Object?> json, String path, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) {
    return value;
  }
  throw FormatException('$path.$key 必须是字符串');
}

double _requiredNumber(Map<String, Object?> json, String path, String key) {
  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('$path.$key 必须是数字');
}

double? _optionalNumber(Map<String, Object?> json, String path, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('$path.$key 必须是数字');
}

bool? _optionalBool(Map<String, Object?> json, String path, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is bool) {
    return value;
  }
  throw FormatException('$path.$key 必须是布尔值');
}

DateTime _requiredDateTime(Map<String, Object?> json, String path, String key) {
  final value = _requiredString(json, path, key);
  final date = DateTime.tryParse(value);
  if (date != null) {
    return date;
  }
  throw FormatException('$path.$key 必须是有效日期字符串');
}

T _enumValue<T>(
  Map<String, Object?> json,
  String path,
  String key,
  T Function(String value) fromName,
) {
  final value = _requiredString(json, path, key);
  return _parseEnumValue(path, key, value, fromName);
}

T? _optionalEnumValue<T>(
  Map<String, Object?> json,
  String path,
  String key,
  T Function(String value) fromName,
) {
  final value = _optionalString(json, path, key);
  if (value == null) return null;
  return _parseEnumValue(path, key, value, fromName);
}

T _parseEnumValue<T>(
  String path,
  String key,
  String value,
  T Function(String value) fromName,
) {
  try {
    return fromName(value);
  } on StateError {
    throw FormatException('$path.$key 的值不支持: $value');
  }
}

MaintenanceCategory _maintenanceCategoryFromName(String value) {
  return MaintenanceCategory.values.firstWhere(
    (category) => category.name == value,
  );
}
