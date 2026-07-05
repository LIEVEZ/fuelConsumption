enum VehicleType {
  fuel,
  electric,
  hybrid,
  motorcycle;

  String get label => switch (this) {
    VehicleType.fuel => '燃油车',
    VehicleType.electric => '电车',
    VehicleType.hybrid => '插混',
    VehicleType.motorcycle => '摩托车',
  };

  static VehicleType fromName(String value) {
    return VehicleType.values.firstWhere((type) => type.name == value);
  }
}

enum EnergyType {
  fuel,
  charge,
  hybrid;

  String get label => switch (this) {
    EnergyType.fuel => '加油',
    EnergyType.charge => '充电',
    EnergyType.hybrid => '油电',
  };

  static EnergyType fromName(String value) {
    return EnergyType.values.firstWhere((type) => type.name == value);
  }
}

enum ChargeMode {
  slow,
  fast;

  String get label => switch (this) {
    ChargeMode.slow => '慢充',
    ChargeMode.fast => '快充',
  };

  static ChargeMode fromName(String value) {
    return ChargeMode.values.firstWhere((mode) => mode.name == value);
  }
}

enum MaintenanceCategory {
  regular,
  oil,
  tire,
  repair,
  wash,
  insurance,
  other;

  String get label => switch (this) {
    MaintenanceCategory.regular => '常规保养',
    MaintenanceCategory.oil => '换机油',
    MaintenanceCategory.tire => '换轮胎',
    MaintenanceCategory.repair => '维修',
    MaintenanceCategory.wash => '洗车',
    MaintenanceCategory.insurance => '保险',
    MaintenanceCategory.other => '其他',
  };

  static MaintenanceCategory fromName(String value) {
    return MaintenanceCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => MaintenanceCategory.other,
    );
  }
}

class Vehicle {
  const Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.initialOdometerKm,
    this.model = '',
    this.isDefault = false,
    this.archived = false,
  });

  final String id;
  final String name;
  final VehicleType type;
  final double initialOdometerKm;
  final String model;
  final bool isDefault;
  final bool archived;

  Vehicle copyWith({
    String? id,
    String? name,
    VehicleType? type,
    double? initialOdometerKm,
    String? model,
    bool? isDefault,
    bool? archived,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialOdometerKm: initialOdometerKm ?? this.initialOdometerKm,
      model: model ?? this.model,
      isDefault: isDefault ?? this.isDefault,
      archived: archived ?? this.archived,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'initialOdometerKm': initialOdometerKm,
    'model': model,
    'isDefault': isDefault,
    'archived': archived,
  };

  factory Vehicle.fromJson(Map<String, Object?> json) {
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

  @override
  bool operator ==(Object other) {
    return other is Vehicle &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.initialOdometerKm == initialOdometerKm &&
        other.model == model &&
        other.isDefault == isDefault &&
        other.archived == archived;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    initialOdometerKm,
    model,
    isDefault,
    archived,
  );
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.category,
    required this.cost,
    this.shop = '',
    this.note = '',
  });

  final String id;
  final String vehicleId;
  final DateTime date;
  final MaintenanceCategory category;
  final double cost;
  final String shop;
  final String note;

  Map<String, Object?> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'date': date.toIso8601String(),
    'category': category.name,
    'cost': cost,
    'shop': shop,
    'note': note,
  };

  factory MaintenanceRecord.fromJson(Map<String, Object?> json) {
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

  @override
  bool operator ==(Object other) {
    return other is MaintenanceRecord &&
        other.id == id &&
        other.vehicleId == vehicleId &&
        other.date == date &&
        other.category == category &&
        other.cost == cost &&
        other.shop == shop &&
        other.note == note;
  }

  @override
  int get hashCode =>
      Object.hash(id, vehicleId, date, category, cost, shop, note);
}

class EnergyRecord {
  const EnergyRecord._({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometerKm,
    required this.energyType,
    required this.amount,
    required this.unitPrice,
    required this.totalCost,
    required this.isFull,
    this.fuelLiters,
    this.kwh,
    this.fuelUnitPrice,
    this.electricityUnitPrice,
    this.chargeMode,
    this.note = '',
  });

  factory EnergyRecord.fuel({
    required String id,
    required String vehicleId,
    required DateTime date,
    required double odometerKm,
    required double liters,
    required double unitPrice,
    required bool isFull,
    String note = '',
  }) {
    return EnergyRecord._(
      id: id,
      vehicleId: vehicleId,
      date: date,
      odometerKm: odometerKm,
      energyType: EnergyType.fuel,
      amount: liters,
      unitPrice: unitPrice,
      totalCost: liters * unitPrice,
      isFull: isFull,
      fuelLiters: liters,
      fuelUnitPrice: unitPrice,
      note: note,
    );
  }

  factory EnergyRecord.charge({
    required String id,
    required String vehicleId,
    required DateTime date,
    required double odometerKm,
    required double kwh,
    required double unitPrice,
    required ChargeMode chargeMode,
    String note = '',
  }) {
    return EnergyRecord._(
      id: id,
      vehicleId: vehicleId,
      date: date,
      odometerKm: odometerKm,
      energyType: EnergyType.charge,
      amount: kwh,
      unitPrice: unitPrice,
      totalCost: kwh * unitPrice,
      isFull: true,
      kwh: kwh,
      electricityUnitPrice: unitPrice,
      chargeMode: chargeMode,
      note: note,
    );
  }

  factory EnergyRecord.hybrid({
    required String id,
    required String vehicleId,
    required DateTime date,
    required double odometerKm,
    required double liters,
    required double fuelUnitPrice,
    required double kwh,
    required double electricityUnitPrice,
    String note = '',
  }) {
    final fuelCost = liters * fuelUnitPrice;
    final electricityCost = kwh * electricityUnitPrice;
    return EnergyRecord._(
      id: id,
      vehicleId: vehicleId,
      date: date,
      odometerKm: odometerKm,
      energyType: EnergyType.hybrid,
      amount: liters + kwh,
      unitPrice: 0,
      totalCost: fuelCost + electricityCost,
      isFull: true,
      fuelLiters: liters,
      kwh: kwh,
      fuelUnitPrice: fuelUnitPrice,
      electricityUnitPrice: electricityUnitPrice,
      note: note,
    );
  }

  final String id;
  final String vehicleId;
  final DateTime date;
  final double odometerKm;
  final EnergyType energyType;
  final double amount;
  final double unitPrice;
  final double totalCost;
  final bool isFull;
  final double? fuelLiters;
  final double? kwh;
  final double? fuelUnitPrice;
  final double? electricityUnitPrice;
  final ChargeMode? chargeMode;
  final String note;

  Map<String, Object?> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'date': date.toIso8601String(),
    'odometerKm': odometerKm,
    'energyType': energyType.name,
    'amount': amount,
    'unitPrice': unitPrice,
    'totalCost': totalCost,
    'isFull': isFull,
    'fuelLiters': fuelLiters,
    'kwh': kwh,
    'fuelUnitPrice': fuelUnitPrice,
    'electricityUnitPrice': electricityUnitPrice,
    'chargeMode': chargeMode?.name,
    'note': note,
  };

  factory EnergyRecord.fromJson(Map<String, Object?> json) {
    final type = EnergyType.fromName(json['energyType'] as String);
    return switch (type) {
      EnergyType.fuel => EnergyRecord.fuel(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        date: DateTime.parse(json['date'] as String),
        odometerKm: (json['odometerKm'] as num).toDouble(),
        liters: (json['fuelLiters'] as num? ?? json['amount'] as num)
            .toDouble(),
        unitPrice: (json['fuelUnitPrice'] as num? ?? json['unitPrice'] as num)
            .toDouble(),
        isFull: json['isFull'] as bool? ?? false,
        note: json['note'] as String? ?? '',
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
        note: json['note'] as String? ?? '',
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
        note: json['note'] as String? ?? '',
      ),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EnergyRecord &&
        other.id == id &&
        other.vehicleId == vehicleId &&
        other.date == date &&
        other.odometerKm == odometerKm &&
        other.energyType == energyType &&
        other.amount == amount &&
        other.unitPrice == unitPrice &&
        other.totalCost == totalCost &&
        other.isFull == isFull &&
        other.fuelLiters == fuelLiters &&
        other.kwh == kwh &&
        other.fuelUnitPrice == fuelUnitPrice &&
        other.electricityUnitPrice == electricityUnitPrice &&
        other.chargeMode == chargeMode &&
        other.note == note;
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    vehicleId,
    date,
    odometerKm,
    energyType,
    amount,
    unitPrice,
    totalCost,
    isFull,
    fuelLiters,
    kwh,
    fuelUnitPrice,
    electricityUnitPrice,
    chargeMode,
    note,
  ]);
}

class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.averageConsumptionLabel,
    required this.latestConsumptionLabel,
    required this.totalCost,
    required this.costPerKm,
    required this.totalDistanceKm,
  });

  final String averageConsumptionLabel;
  final String latestConsumptionLabel;
  final double totalCost;
  final double costPerKm;
  final double totalDistanceKm;
}

class BackupData {
  const BackupData({
    required this.schemaVersion,
    required this.exportedAt,
    required this.vehicles,
    required this.records,
    this.maintenanceRecords = const [],
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final List<Vehicle> vehicles;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;
}
