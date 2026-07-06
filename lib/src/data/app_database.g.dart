// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehicleRowsTable extends VehicleRows
    with TableInfo<$VehicleRowsTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialOdometerKmMeta = const VerificationMeta(
    'initialOdometerKm',
  );
  @override
  late final GeneratedColumn<double> initialOdometerKm =
      GeneratedColumn<double>(
        'initial_odometer_km',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    initialOdometerKm,
    model,
    isDefault,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('initial_odometer_km')) {
      context.handle(
        _initialOdometerKmMeta,
        initialOdometerKm.isAcceptableOrUnknown(
          data['initial_odometer_km']!,
          _initialOdometerKmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialOdometerKmMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      initialOdometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_odometer_km'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $VehicleRowsTable createAlias(String alias) {
    return $VehicleRowsTable(attachedDatabase, alias);
  }
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final String id;
  final String name;
  final String type;
  final double initialOdometerKm;
  final String model;
  final bool isDefault;
  final bool archived;
  const VehicleRow({
    required this.id,
    required this.name,
    required this.type,
    required this.initialOdometerKm,
    required this.model,
    required this.isDefault,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['initial_odometer_km'] = Variable<double>(initialOdometerKm);
    map['model'] = Variable<String>(model);
    map['is_default'] = Variable<bool>(isDefault);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  VehicleRowsCompanion toCompanion(bool nullToAbsent) {
    return VehicleRowsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      initialOdometerKm: Value(initialOdometerKm),
      model: Value(model),
      isDefault: Value(isDefault),
      archived: Value(archived),
    );
  }

  factory VehicleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      initialOdometerKm: serializer.fromJson<double>(json['initialOdometerKm']),
      model: serializer.fromJson<String>(json['model']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'initialOdometerKm': serializer.toJson<double>(initialOdometerKm),
      'model': serializer.toJson<String>(model),
      'isDefault': serializer.toJson<bool>(isDefault),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  VehicleRow copyWith({
    String? id,
    String? name,
    String? type,
    double? initialOdometerKm,
    String? model,
    bool? isDefault,
    bool? archived,
  }) => VehicleRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    initialOdometerKm: initialOdometerKm ?? this.initialOdometerKm,
    model: model ?? this.model,
    isDefault: isDefault ?? this.isDefault,
    archived: archived ?? this.archived,
  );
  VehicleRow copyWithCompanion(VehicleRowsCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      initialOdometerKm: data.initialOdometerKm.present
          ? data.initialOdometerKm.value
          : this.initialOdometerKm,
      model: data.model.present ? data.model.value : this.model,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialOdometerKm: $initialOdometerKm, ')
          ..write('model: $model, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.initialOdometerKm == this.initialOdometerKm &&
          other.model == this.model &&
          other.isDefault == this.isDefault &&
          other.archived == this.archived);
}

class VehicleRowsCompanion extends UpdateCompanion<VehicleRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> initialOdometerKm;
  final Value<String> model;
  final Value<bool> isDefault;
  final Value<bool> archived;
  final Value<int> rowid;
  const VehicleRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.initialOdometerKm = const Value.absent(),
    this.model = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleRowsCompanion.insert({
    required String id,
    required String name,
    required String type,
    required double initialOdometerKm,
    this.model = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       initialOdometerKm = Value(initialOdometerKm);
  static Insertable<VehicleRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? initialOdometerKm,
    Expression<String>? model,
    Expression<bool>? isDefault,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (initialOdometerKm != null) 'initial_odometer_km': initialOdometerKm,
      if (model != null) 'model': model,
      if (isDefault != null) 'is_default': isDefault,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? initialOdometerKm,
    Value<String>? model,
    Value<bool>? isDefault,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return VehicleRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialOdometerKm: initialOdometerKm ?? this.initialOdometerKm,
      model: model ?? this.model,
      isDefault: isDefault ?? this.isDefault,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (initialOdometerKm.present) {
      map['initial_odometer_km'] = Variable<double>(initialOdometerKm.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialOdometerKm: $initialOdometerKm, ')
          ..write('model: $model, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnergyRecordRowsTable extends EnergyRecordRows
    with TableInfo<$EnergyRecordRowsTable, EnergyRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyRecordRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_rows (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyTypeMeta = const VerificationMeta(
    'energyType',
  );
  @override
  late final GeneratedColumn<String> energyType = GeneratedColumn<String>(
    'energy_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFullMeta = const VerificationMeta('isFull');
  @override
  late final GeneratedColumn<bool> isFull = GeneratedColumn<bool>(
    'is_full',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_full" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fuelLitersMeta = const VerificationMeta(
    'fuelLiters',
  );
  @override
  late final GeneratedColumn<double> fuelLiters = GeneratedColumn<double>(
    'fuel_liters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kwhMeta = const VerificationMeta('kwh');
  @override
  late final GeneratedColumn<double> kwh = GeneratedColumn<double>(
    'kwh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelUnitPriceMeta = const VerificationMeta(
    'fuelUnitPrice',
  );
  @override
  late final GeneratedColumn<double> fuelUnitPrice = GeneratedColumn<double>(
    'fuel_unit_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _electricityUnitPriceMeta =
      const VerificationMeta('electricityUnitPrice');
  @override
  late final GeneratedColumn<double> electricityUnitPrice =
      GeneratedColumn<double>(
        'electricity_unit_price',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _chargeModeMeta = const VerificationMeta(
    'chargeMode',
  );
  @override
  late final GeneratedColumn<String> chargeMode = GeneratedColumn<String>(
    'charge_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _machineAmountMeta = const VerificationMeta(
    'machineAmount',
  );
  @override
  late final GeneratedColumn<double> machineAmount = GeneratedColumn<double>(
    'machine_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
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
    machineAmount,
    paidAmount,
    discountAmount,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_record_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnergyRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerKmMeta);
    }
    if (data.containsKey('energy_type')) {
      context.handle(
        _energyTypeMeta,
        energyType.isAcceptableOrUnknown(data['energy_type']!, _energyTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_energyTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCostMeta);
    }
    if (data.containsKey('is_full')) {
      context.handle(
        _isFullMeta,
        isFull.isAcceptableOrUnknown(data['is_full']!, _isFullMeta),
      );
    }
    if (data.containsKey('fuel_liters')) {
      context.handle(
        _fuelLitersMeta,
        fuelLiters.isAcceptableOrUnknown(data['fuel_liters']!, _fuelLitersMeta),
      );
    }
    if (data.containsKey('kwh')) {
      context.handle(
        _kwhMeta,
        kwh.isAcceptableOrUnknown(data['kwh']!, _kwhMeta),
      );
    }
    if (data.containsKey('fuel_unit_price')) {
      context.handle(
        _fuelUnitPriceMeta,
        fuelUnitPrice.isAcceptableOrUnknown(
          data['fuel_unit_price']!,
          _fuelUnitPriceMeta,
        ),
      );
    }
    if (data.containsKey('electricity_unit_price')) {
      context.handle(
        _electricityUnitPriceMeta,
        electricityUnitPrice.isAcceptableOrUnknown(
          data['electricity_unit_price']!,
          _electricityUnitPriceMeta,
        ),
      );
    }
    if (data.containsKey('charge_mode')) {
      context.handle(
        _chargeModeMeta,
        chargeMode.isAcceptableOrUnknown(data['charge_mode']!, _chargeModeMeta),
      );
    }
    if (data.containsKey('machine_amount')) {
      context.handle(
        _machineAmountMeta,
        machineAmount.isAcceptableOrUnknown(
          data['machine_amount']!,
          _machineAmountMeta,
        ),
      );
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      )!,
      energyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}energy_type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      )!,
      isFull: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_full'],
      )!,
      fuelLiters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuel_liters'],
      ),
      kwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kwh'],
      ),
      fuelUnitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuel_unit_price'],
      ),
      electricityUnitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}electricity_unit_price'],
      ),
      chargeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}charge_mode'],
      ),
      machineAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}machine_amount'],
      ),
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      ),
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $EnergyRecordRowsTable createAlias(String alias) {
    return $EnergyRecordRowsTable(attachedDatabase, alias);
  }
}

class EnergyRecordRow extends DataClass implements Insertable<EnergyRecordRow> {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double odometerKm;
  final String energyType;
  final double amount;
  final double unitPrice;
  final double totalCost;
  final bool isFull;
  final double? fuelLiters;
  final double? kwh;
  final double? fuelUnitPrice;
  final double? electricityUnitPrice;
  final String? chargeMode;
  final double? machineAmount;
  final double? paidAmount;
  final double? discountAmount;
  final String note;
  const EnergyRecordRow({
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
    this.machineAmount,
    this.paidAmount,
    this.discountAmount,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['date'] = Variable<DateTime>(date);
    map['odometer_km'] = Variable<double>(odometerKm);
    map['energy_type'] = Variable<String>(energyType);
    map['amount'] = Variable<double>(amount);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_cost'] = Variable<double>(totalCost);
    map['is_full'] = Variable<bool>(isFull);
    if (!nullToAbsent || fuelLiters != null) {
      map['fuel_liters'] = Variable<double>(fuelLiters);
    }
    if (!nullToAbsent || kwh != null) {
      map['kwh'] = Variable<double>(kwh);
    }
    if (!nullToAbsent || fuelUnitPrice != null) {
      map['fuel_unit_price'] = Variable<double>(fuelUnitPrice);
    }
    if (!nullToAbsent || electricityUnitPrice != null) {
      map['electricity_unit_price'] = Variable<double>(electricityUnitPrice);
    }
    if (!nullToAbsent || chargeMode != null) {
      map['charge_mode'] = Variable<String>(chargeMode);
    }
    if (!nullToAbsent || machineAmount != null) {
      map['machine_amount'] = Variable<double>(machineAmount);
    }
    if (!nullToAbsent || paidAmount != null) {
      map['paid_amount'] = Variable<double>(paidAmount);
    }
    if (!nullToAbsent || discountAmount != null) {
      map['discount_amount'] = Variable<double>(discountAmount);
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  EnergyRecordRowsCompanion toCompanion(bool nullToAbsent) {
    return EnergyRecordRowsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      date: Value(date),
      odometerKm: Value(odometerKm),
      energyType: Value(energyType),
      amount: Value(amount),
      unitPrice: Value(unitPrice),
      totalCost: Value(totalCost),
      isFull: Value(isFull),
      fuelLiters: fuelLiters == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelLiters),
      kwh: kwh == null && nullToAbsent ? const Value.absent() : Value(kwh),
      fuelUnitPrice: fuelUnitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelUnitPrice),
      electricityUnitPrice: electricityUnitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(electricityUnitPrice),
      chargeMode: chargeMode == null && nullToAbsent
          ? const Value.absent()
          : Value(chargeMode),
      machineAmount: machineAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(machineAmount),
      paidAmount: paidAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAmount),
      discountAmount: discountAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(discountAmount),
      note: Value(note),
    );
  }

  factory EnergyRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyRecordRow(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      date: serializer.fromJson<DateTime>(json['date']),
      odometerKm: serializer.fromJson<double>(json['odometerKm']),
      energyType: serializer.fromJson<String>(json['energyType']),
      amount: serializer.fromJson<double>(json['amount']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
      isFull: serializer.fromJson<bool>(json['isFull']),
      fuelLiters: serializer.fromJson<double?>(json['fuelLiters']),
      kwh: serializer.fromJson<double?>(json['kwh']),
      fuelUnitPrice: serializer.fromJson<double?>(json['fuelUnitPrice']),
      electricityUnitPrice: serializer.fromJson<double?>(
        json['electricityUnitPrice'],
      ),
      chargeMode: serializer.fromJson<String?>(json['chargeMode']),
      machineAmount: serializer.fromJson<double?>(json['machineAmount']),
      paidAmount: serializer.fromJson<double?>(json['paidAmount']),
      discountAmount: serializer.fromJson<double?>(json['discountAmount']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'date': serializer.toJson<DateTime>(date),
      'odometerKm': serializer.toJson<double>(odometerKm),
      'energyType': serializer.toJson<String>(energyType),
      'amount': serializer.toJson<double>(amount),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalCost': serializer.toJson<double>(totalCost),
      'isFull': serializer.toJson<bool>(isFull),
      'fuelLiters': serializer.toJson<double?>(fuelLiters),
      'kwh': serializer.toJson<double?>(kwh),
      'fuelUnitPrice': serializer.toJson<double?>(fuelUnitPrice),
      'electricityUnitPrice': serializer.toJson<double?>(electricityUnitPrice),
      'chargeMode': serializer.toJson<String?>(chargeMode),
      'machineAmount': serializer.toJson<double?>(machineAmount),
      'paidAmount': serializer.toJson<double?>(paidAmount),
      'discountAmount': serializer.toJson<double?>(discountAmount),
      'note': serializer.toJson<String>(note),
    };
  }

  EnergyRecordRow copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    double? odometerKm,
    String? energyType,
    double? amount,
    double? unitPrice,
    double? totalCost,
    bool? isFull,
    Value<double?> fuelLiters = const Value.absent(),
    Value<double?> kwh = const Value.absent(),
    Value<double?> fuelUnitPrice = const Value.absent(),
    Value<double?> electricityUnitPrice = const Value.absent(),
    Value<String?> chargeMode = const Value.absent(),
    Value<double?> machineAmount = const Value.absent(),
    Value<double?> paidAmount = const Value.absent(),
    Value<double?> discountAmount = const Value.absent(),
    String? note,
  }) => EnergyRecordRow(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    date: date ?? this.date,
    odometerKm: odometerKm ?? this.odometerKm,
    energyType: energyType ?? this.energyType,
    amount: amount ?? this.amount,
    unitPrice: unitPrice ?? this.unitPrice,
    totalCost: totalCost ?? this.totalCost,
    isFull: isFull ?? this.isFull,
    fuelLiters: fuelLiters.present ? fuelLiters.value : this.fuelLiters,
    kwh: kwh.present ? kwh.value : this.kwh,
    fuelUnitPrice: fuelUnitPrice.present
        ? fuelUnitPrice.value
        : this.fuelUnitPrice,
    electricityUnitPrice: electricityUnitPrice.present
        ? electricityUnitPrice.value
        : this.electricityUnitPrice,
    chargeMode: chargeMode.present ? chargeMode.value : this.chargeMode,
    machineAmount: machineAmount.present
        ? machineAmount.value
        : this.machineAmount,
    paidAmount: paidAmount.present ? paidAmount.value : this.paidAmount,
    discountAmount: discountAmount.present
        ? discountAmount.value
        : this.discountAmount,
    note: note ?? this.note,
  );
  EnergyRecordRow copyWithCompanion(EnergyRecordRowsCompanion data) {
    return EnergyRecordRow(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      date: data.date.present ? data.date.value : this.date,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      energyType: data.energyType.present
          ? data.energyType.value
          : this.energyType,
      amount: data.amount.present ? data.amount.value : this.amount,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      isFull: data.isFull.present ? data.isFull.value : this.isFull,
      fuelLiters: data.fuelLiters.present
          ? data.fuelLiters.value
          : this.fuelLiters,
      kwh: data.kwh.present ? data.kwh.value : this.kwh,
      fuelUnitPrice: data.fuelUnitPrice.present
          ? data.fuelUnitPrice.value
          : this.fuelUnitPrice,
      electricityUnitPrice: data.electricityUnitPrice.present
          ? data.electricityUnitPrice.value
          : this.electricityUnitPrice,
      chargeMode: data.chargeMode.present
          ? data.chargeMode.value
          : this.chargeMode,
      machineAmount: data.machineAmount.present
          ? data.machineAmount.value
          : this.machineAmount,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyRecordRow(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('energyType: $energyType, ')
          ..write('amount: $amount, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalCost: $totalCost, ')
          ..write('isFull: $isFull, ')
          ..write('fuelLiters: $fuelLiters, ')
          ..write('kwh: $kwh, ')
          ..write('fuelUnitPrice: $fuelUnitPrice, ')
          ..write('electricityUnitPrice: $electricityUnitPrice, ')
          ..write('chargeMode: $chargeMode, ')
          ..write('machineAmount: $machineAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    machineAmount,
    paidAmount,
    discountAmount,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyRecordRow &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.date == this.date &&
          other.odometerKm == this.odometerKm &&
          other.energyType == this.energyType &&
          other.amount == this.amount &&
          other.unitPrice == this.unitPrice &&
          other.totalCost == this.totalCost &&
          other.isFull == this.isFull &&
          other.fuelLiters == this.fuelLiters &&
          other.kwh == this.kwh &&
          other.fuelUnitPrice == this.fuelUnitPrice &&
          other.electricityUnitPrice == this.electricityUnitPrice &&
          other.chargeMode == this.chargeMode &&
          other.machineAmount == this.machineAmount &&
          other.paidAmount == this.paidAmount &&
          other.discountAmount == this.discountAmount &&
          other.note == this.note);
}

class EnergyRecordRowsCompanion extends UpdateCompanion<EnergyRecordRow> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<DateTime> date;
  final Value<double> odometerKm;
  final Value<String> energyType;
  final Value<double> amount;
  final Value<double> unitPrice;
  final Value<double> totalCost;
  final Value<bool> isFull;
  final Value<double?> fuelLiters;
  final Value<double?> kwh;
  final Value<double?> fuelUnitPrice;
  final Value<double?> electricityUnitPrice;
  final Value<String?> chargeMode;
  final Value<double?> machineAmount;
  final Value<double?> paidAmount;
  final Value<double?> discountAmount;
  final Value<String> note;
  final Value<int> rowid;
  const EnergyRecordRowsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.date = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.energyType = const Value.absent(),
    this.amount = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.isFull = const Value.absent(),
    this.fuelLiters = const Value.absent(),
    this.kwh = const Value.absent(),
    this.fuelUnitPrice = const Value.absent(),
    this.electricityUnitPrice = const Value.absent(),
    this.chargeMode = const Value.absent(),
    this.machineAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnergyRecordRowsCompanion.insert({
    required String id,
    required String vehicleId,
    required DateTime date,
    required double odometerKm,
    required String energyType,
    required double amount,
    required double unitPrice,
    required double totalCost,
    this.isFull = const Value.absent(),
    this.fuelLiters = const Value.absent(),
    this.kwh = const Value.absent(),
    this.fuelUnitPrice = const Value.absent(),
    this.electricityUnitPrice = const Value.absent(),
    this.chargeMode = const Value.absent(),
    this.machineAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       date = Value(date),
       odometerKm = Value(odometerKm),
       energyType = Value(energyType),
       amount = Value(amount),
       unitPrice = Value(unitPrice),
       totalCost = Value(totalCost);
  static Insertable<EnergyRecordRow> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<DateTime>? date,
    Expression<double>? odometerKm,
    Expression<String>? energyType,
    Expression<double>? amount,
    Expression<double>? unitPrice,
    Expression<double>? totalCost,
    Expression<bool>? isFull,
    Expression<double>? fuelLiters,
    Expression<double>? kwh,
    Expression<double>? fuelUnitPrice,
    Expression<double>? electricityUnitPrice,
    Expression<String>? chargeMode,
    Expression<double>? machineAmount,
    Expression<double>? paidAmount,
    Expression<double>? discountAmount,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (date != null) 'date': date,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (energyType != null) 'energy_type': energyType,
      if (amount != null) 'amount': amount,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalCost != null) 'total_cost': totalCost,
      if (isFull != null) 'is_full': isFull,
      if (fuelLiters != null) 'fuel_liters': fuelLiters,
      if (kwh != null) 'kwh': kwh,
      if (fuelUnitPrice != null) 'fuel_unit_price': fuelUnitPrice,
      if (electricityUnitPrice != null)
        'electricity_unit_price': electricityUnitPrice,
      if (chargeMode != null) 'charge_mode': chargeMode,
      if (machineAmount != null) 'machine_amount': machineAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnergyRecordRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<DateTime>? date,
    Value<double>? odometerKm,
    Value<String>? energyType,
    Value<double>? amount,
    Value<double>? unitPrice,
    Value<double>? totalCost,
    Value<bool>? isFull,
    Value<double?>? fuelLiters,
    Value<double?>? kwh,
    Value<double?>? fuelUnitPrice,
    Value<double?>? electricityUnitPrice,
    Value<String?>? chargeMode,
    Value<double?>? machineAmount,
    Value<double?>? paidAmount,
    Value<double?>? discountAmount,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return EnergyRecordRowsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      odometerKm: odometerKm ?? this.odometerKm,
      energyType: energyType ?? this.energyType,
      amount: amount ?? this.amount,
      unitPrice: unitPrice ?? this.unitPrice,
      totalCost: totalCost ?? this.totalCost,
      isFull: isFull ?? this.isFull,
      fuelLiters: fuelLiters ?? this.fuelLiters,
      kwh: kwh ?? this.kwh,
      fuelUnitPrice: fuelUnitPrice ?? this.fuelUnitPrice,
      electricityUnitPrice: electricityUnitPrice ?? this.electricityUnitPrice,
      chargeMode: chargeMode ?? this.chargeMode,
      machineAmount: machineAmount ?? this.machineAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (energyType.present) {
      map['energy_type'] = Variable<String>(energyType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (isFull.present) {
      map['is_full'] = Variable<bool>(isFull.value);
    }
    if (fuelLiters.present) {
      map['fuel_liters'] = Variable<double>(fuelLiters.value);
    }
    if (kwh.present) {
      map['kwh'] = Variable<double>(kwh.value);
    }
    if (fuelUnitPrice.present) {
      map['fuel_unit_price'] = Variable<double>(fuelUnitPrice.value);
    }
    if (electricityUnitPrice.present) {
      map['electricity_unit_price'] = Variable<double>(
        electricityUnitPrice.value,
      );
    }
    if (chargeMode.present) {
      map['charge_mode'] = Variable<String>(chargeMode.value);
    }
    if (machineAmount.present) {
      map['machine_amount'] = Variable<double>(machineAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyRecordRowsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('energyType: $energyType, ')
          ..write('amount: $amount, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalCost: $totalCost, ')
          ..write('isFull: $isFull, ')
          ..write('fuelLiters: $fuelLiters, ')
          ..write('kwh: $kwh, ')
          ..write('fuelUnitPrice: $fuelUnitPrice, ')
          ..write('electricityUnitPrice: $electricityUnitPrice, ')
          ..write('chargeMode: $chargeMode, ')
          ..write('machineAmount: $machineAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceRecordRowsTable extends MaintenanceRecordRows
    with TableInfo<$MaintenanceRecordRowsTable, MaintenanceRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceRecordRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_rows (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shopMeta = const VerificationMeta('shop');
  @override
  late final GeneratedColumn<String> shop = GeneratedColumn<String>(
    'shop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    date,
    category,
    cost,
    shop,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_record_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('shop')) {
      context.handle(
        _shopMeta,
        shop.isAcceptableOrUnknown(data['shop']!, _shopMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      shop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $MaintenanceRecordRowsTable createAlias(String alias) {
    return $MaintenanceRecordRowsTable(attachedDatabase, alias);
  }
}

class MaintenanceRecordRow extends DataClass
    implements Insertable<MaintenanceRecordRow> {
  final String id;
  final String vehicleId;
  final DateTime date;
  final String category;
  final double cost;
  final String shop;
  final String note;
  const MaintenanceRecordRow({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.category,
    required this.cost,
    required this.shop,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    map['cost'] = Variable<double>(cost);
    map['shop'] = Variable<String>(shop);
    map['note'] = Variable<String>(note);
    return map;
  }

  MaintenanceRecordRowsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceRecordRowsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      date: Value(date),
      category: Value(category),
      cost: Value(cost),
      shop: Value(shop),
      note: Value(note),
    );
  }

  factory MaintenanceRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceRecordRow(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      cost: serializer.fromJson<double>(json['cost']),
      shop: serializer.fromJson<String>(json['shop']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'cost': serializer.toJson<double>(cost),
      'shop': serializer.toJson<String>(shop),
      'note': serializer.toJson<String>(note),
    };
  }

  MaintenanceRecordRow copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    String? category,
    double? cost,
    String? shop,
    String? note,
  }) => MaintenanceRecordRow(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    date: date ?? this.date,
    category: category ?? this.category,
    cost: cost ?? this.cost,
    shop: shop ?? this.shop,
    note: note ?? this.note,
  );
  MaintenanceRecordRow copyWithCompanion(MaintenanceRecordRowsCompanion data) {
    return MaintenanceRecordRow(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      cost: data.cost.present ? data.cost.value : this.cost,
      shop: data.shop.present ? data.shop.value : this.shop,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecordRow(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('cost: $cost, ')
          ..write('shop: $shop, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vehicleId, date, category, cost, shop, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceRecordRow &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.date == this.date &&
          other.category == this.category &&
          other.cost == this.cost &&
          other.shop == this.shop &&
          other.note == this.note);
}

class MaintenanceRecordRowsCompanion
    extends UpdateCompanion<MaintenanceRecordRow> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<double> cost;
  final Value<String> shop;
  final Value<String> note;
  final Value<int> rowid;
  const MaintenanceRecordRowsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.cost = const Value.absent(),
    this.shop = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaintenanceRecordRowsCompanion.insert({
    required String id,
    required String vehicleId,
    required DateTime date,
    required String category,
    required double cost,
    this.shop = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vehicleId = Value(vehicleId),
       date = Value(date),
       category = Value(category),
       cost = Value(cost);
  static Insertable<MaintenanceRecordRow> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<double>? cost,
    Expression<String>? shop,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (cost != null) 'cost': cost,
      if (shop != null) 'shop': shop,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaintenanceRecordRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? vehicleId,
    Value<DateTime>? date,
    Value<String>? category,
    Value<double>? cost,
    Value<String>? shop,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return MaintenanceRecordRowsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      shop: shop ?? this.shop,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (shop.present) {
      map['shop'] = Variable<String>(shop.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecordRowsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('cost: $cost, ')
          ..write('shop: $shop, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehicleRowsTable vehicleRows = $VehicleRowsTable(this);
  late final $EnergyRecordRowsTable energyRecordRows = $EnergyRecordRowsTable(
    this,
  );
  late final $MaintenanceRecordRowsTable maintenanceRecordRows =
      $MaintenanceRecordRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicleRows,
    energyRecordRows,
    maintenanceRecordRows,
  ];
}

typedef $$VehicleRowsTableCreateCompanionBuilder =
    VehicleRowsCompanion Function({
      required String id,
      required String name,
      required String type,
      required double initialOdometerKm,
      Value<String> model,
      Value<bool> isDefault,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$VehicleRowsTableUpdateCompanionBuilder =
    VehicleRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<double> initialOdometerKm,
      Value<String> model,
      Value<bool> isDefault,
      Value<bool> archived,
      Value<int> rowid,
    });

final class $$VehicleRowsTableReferences
    extends BaseReferences<_$AppDatabase, $VehicleRowsTable, VehicleRow> {
  $$VehicleRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EnergyRecordRowsTable, List<EnergyRecordRow>>
  _energyRecordRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.energyRecordRows,
    aliasName: 'vehicle_rows__id__energy_record_rows__vehicle_id',
  );

  $$EnergyRecordRowsTableProcessedTableManager get energyRecordRowsRefs {
    final manager = $$EnergyRecordRowsTableTableManager(
      $_db,
      $_db.energyRecordRows,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _energyRecordRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MaintenanceRecordRowsTable,
    List<MaintenanceRecordRow>
  >
  _maintenanceRecordRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceRecordRows,
        aliasName: 'vehicle_rows__id__maintenance_record_rows__vehicle_id',
      );

  $$MaintenanceRecordRowsTableProcessedTableManager
  get maintenanceRecordRowsRefs {
    final manager = $$MaintenanceRecordRowsTableTableManager(
      $_db,
      $_db.maintenanceRecordRows,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRecordRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehicleRowsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleRowsTable> {
  $$VehicleRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialOdometerKm => $composableBuilder(
    column: $table.initialOdometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> energyRecordRowsRefs(
    Expression<bool> Function($$EnergyRecordRowsTableFilterComposer f) f,
  ) {
    final $$EnergyRecordRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.energyRecordRows,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnergyRecordRowsTableFilterComposer(
            $db: $db,
            $table: $db.energyRecordRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceRecordRowsRefs(
    Expression<bool> Function($$MaintenanceRecordRowsTableFilterComposer f) f,
  ) {
    final $$MaintenanceRecordRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRecordRows,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordRowsTableFilterComposer(
                $db: $db,
                $table: $db.maintenanceRecordRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehicleRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleRowsTable> {
  $$VehicleRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialOdometerKm => $composableBuilder(
    column: $table.initialOdometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehicleRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleRowsTable> {
  $$VehicleRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get initialOdometerKm => $composableBuilder(
    column: $table.initialOdometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> energyRecordRowsRefs<T extends Object>(
    Expression<T> Function($$EnergyRecordRowsTableAnnotationComposer a) f,
  ) {
    final $$EnergyRecordRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.energyRecordRows,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnergyRecordRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.energyRecordRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceRecordRowsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRecordRowsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRecordRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRecordRows,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRecordRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehicleRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleRowsTable,
          VehicleRow,
          $$VehicleRowsTableFilterComposer,
          $$VehicleRowsTableOrderingComposer,
          $$VehicleRowsTableAnnotationComposer,
          $$VehicleRowsTableCreateCompanionBuilder,
          $$VehicleRowsTableUpdateCompanionBuilder,
          (VehicleRow, $$VehicleRowsTableReferences),
          VehicleRow,
          PrefetchHooks Function({
            bool energyRecordRowsRefs,
            bool maintenanceRecordRowsRefs,
          })
        > {
  $$VehicleRowsTableTableManager(_$AppDatabase db, $VehicleRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> initialOdometerKm = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleRowsCompanion(
                id: id,
                name: name,
                type: type,
                initialOdometerKm: initialOdometerKm,
                model: model,
                isDefault: isDefault,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required double initialOdometerKm,
                Value<String> model = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleRowsCompanion.insert(
                id: id,
                name: name,
                type: type,
                initialOdometerKm: initialOdometerKm,
                model: model,
                isDefault: isDefault,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehicleRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                energyRecordRowsRefs = false,
                maintenanceRecordRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (energyRecordRowsRefs) db.energyRecordRows,
                    if (maintenanceRecordRowsRefs) db.maintenanceRecordRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (energyRecordRowsRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehicleRowsTable,
                          EnergyRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehicleRowsTableReferences
                              ._energyRecordRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehicleRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).energyRecordRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceRecordRowsRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehicleRowsTable,
                          MaintenanceRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehicleRowsTableReferences
                              ._maintenanceRecordRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehicleRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRecordRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehicleRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleRowsTable,
      VehicleRow,
      $$VehicleRowsTableFilterComposer,
      $$VehicleRowsTableOrderingComposer,
      $$VehicleRowsTableAnnotationComposer,
      $$VehicleRowsTableCreateCompanionBuilder,
      $$VehicleRowsTableUpdateCompanionBuilder,
      (VehicleRow, $$VehicleRowsTableReferences),
      VehicleRow,
      PrefetchHooks Function({
        bool energyRecordRowsRefs,
        bool maintenanceRecordRowsRefs,
      })
    >;
typedef $$EnergyRecordRowsTableCreateCompanionBuilder =
    EnergyRecordRowsCompanion Function({
      required String id,
      required String vehicleId,
      required DateTime date,
      required double odometerKm,
      required String energyType,
      required double amount,
      required double unitPrice,
      required double totalCost,
      Value<bool> isFull,
      Value<double?> fuelLiters,
      Value<double?> kwh,
      Value<double?> fuelUnitPrice,
      Value<double?> electricityUnitPrice,
      Value<String?> chargeMode,
      Value<double?> machineAmount,
      Value<double?> paidAmount,
      Value<double?> discountAmount,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$EnergyRecordRowsTableUpdateCompanionBuilder =
    EnergyRecordRowsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<DateTime> date,
      Value<double> odometerKm,
      Value<String> energyType,
      Value<double> amount,
      Value<double> unitPrice,
      Value<double> totalCost,
      Value<bool> isFull,
      Value<double?> fuelLiters,
      Value<double?> kwh,
      Value<double?> fuelUnitPrice,
      Value<double?> electricityUnitPrice,
      Value<String?> chargeMode,
      Value<double?> machineAmount,
      Value<double?> paidAmount,
      Value<double?> discountAmount,
      Value<String> note,
      Value<int> rowid,
    });

final class $$EnergyRecordRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $EnergyRecordRowsTable, EnergyRecordRow> {
  $$EnergyRecordRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehicleRowsTable _vehicleIdTable(_$AppDatabase db) => db.vehicleRows
      .createAlias('energy_record_rows__vehicle_id__vehicle_rows__id');

  $$VehicleRowsTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehicleRowsTableTableManager(
      $_db,
      $_db.vehicleRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnergyRecordRowsTableFilterComposer
    extends Composer<_$AppDatabase, $EnergyRecordRowsTable> {
  $$EnergyRecordRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get energyType => $composableBuilder(
    column: $table.energyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFull => $composableBuilder(
    column: $table.isFull,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fuelLiters => $composableBuilder(
    column: $table.fuelLiters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kwh => $composableBuilder(
    column: $table.kwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fuelUnitPrice => $composableBuilder(
    column: $table.fuelUnitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get electricityUnitPrice => $composableBuilder(
    column: $table.electricityUnitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chargeMode => $composableBuilder(
    column: $table.chargeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get machineAmount => $composableBuilder(
    column: $table.machineAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$VehicleRowsTableFilterComposer get vehicleId {
    final $$VehicleRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleRowsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnergyRecordRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnergyRecordRowsTable> {
  $$EnergyRecordRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energyType => $composableBuilder(
    column: $table.energyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFull => $composableBuilder(
    column: $table.isFull,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fuelLiters => $composableBuilder(
    column: $table.fuelLiters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kwh => $composableBuilder(
    column: $table.kwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fuelUnitPrice => $composableBuilder(
    column: $table.fuelUnitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get electricityUnitPrice => $composableBuilder(
    column: $table.electricityUnitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chargeMode => $composableBuilder(
    column: $table.chargeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get machineAmount => $composableBuilder(
    column: $table.machineAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehicleRowsTableOrderingComposer get vehicleId {
    final $$VehicleRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleRowsTableOrderingComposer(
            $db: $db,
            $table: $db.vehicleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnergyRecordRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnergyRecordRowsTable> {
  $$EnergyRecordRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get energyType => $composableBuilder(
    column: $table.energyType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<bool> get isFull =>
      $composableBuilder(column: $table.isFull, builder: (column) => column);

  GeneratedColumn<double> get fuelLiters => $composableBuilder(
    column: $table.fuelLiters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kwh =>
      $composableBuilder(column: $table.kwh, builder: (column) => column);

  GeneratedColumn<double> get fuelUnitPrice => $composableBuilder(
    column: $table.fuelUnitPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get electricityUnitPrice => $composableBuilder(
    column: $table.electricityUnitPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chargeMode => $composableBuilder(
    column: $table.chargeMode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get machineAmount => $composableBuilder(
    column: $table.machineAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$VehicleRowsTableAnnotationComposer get vehicleId {
    final $$VehicleRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnergyRecordRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnergyRecordRowsTable,
          EnergyRecordRow,
          $$EnergyRecordRowsTableFilterComposer,
          $$EnergyRecordRowsTableOrderingComposer,
          $$EnergyRecordRowsTableAnnotationComposer,
          $$EnergyRecordRowsTableCreateCompanionBuilder,
          $$EnergyRecordRowsTableUpdateCompanionBuilder,
          (EnergyRecordRow, $$EnergyRecordRowsTableReferences),
          EnergyRecordRow,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$EnergyRecordRowsTableTableManager(
    _$AppDatabase db,
    $EnergyRecordRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnergyRecordRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnergyRecordRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnergyRecordRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> odometerKm = const Value.absent(),
                Value<String> energyType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalCost = const Value.absent(),
                Value<bool> isFull = const Value.absent(),
                Value<double?> fuelLiters = const Value.absent(),
                Value<double?> kwh = const Value.absent(),
                Value<double?> fuelUnitPrice = const Value.absent(),
                Value<double?> electricityUnitPrice = const Value.absent(),
                Value<String?> chargeMode = const Value.absent(),
                Value<double?> machineAmount = const Value.absent(),
                Value<double?> paidAmount = const Value.absent(),
                Value<double?> discountAmount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnergyRecordRowsCompanion(
                id: id,
                vehicleId: vehicleId,
                date: date,
                odometerKm: odometerKm,
                energyType: energyType,
                amount: amount,
                unitPrice: unitPrice,
                totalCost: totalCost,
                isFull: isFull,
                fuelLiters: fuelLiters,
                kwh: kwh,
                fuelUnitPrice: fuelUnitPrice,
                electricityUnitPrice: electricityUnitPrice,
                chargeMode: chargeMode,
                machineAmount: machineAmount,
                paidAmount: paidAmount,
                discountAmount: discountAmount,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required DateTime date,
                required double odometerKm,
                required String energyType,
                required double amount,
                required double unitPrice,
                required double totalCost,
                Value<bool> isFull = const Value.absent(),
                Value<double?> fuelLiters = const Value.absent(),
                Value<double?> kwh = const Value.absent(),
                Value<double?> fuelUnitPrice = const Value.absent(),
                Value<double?> electricityUnitPrice = const Value.absent(),
                Value<String?> chargeMode = const Value.absent(),
                Value<double?> machineAmount = const Value.absent(),
                Value<double?> paidAmount = const Value.absent(),
                Value<double?> discountAmount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnergyRecordRowsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                date: date,
                odometerKm: odometerKm,
                energyType: energyType,
                amount: amount,
                unitPrice: unitPrice,
                totalCost: totalCost,
                isFull: isFull,
                fuelLiters: fuelLiters,
                kwh: kwh,
                fuelUnitPrice: fuelUnitPrice,
                electricityUnitPrice: electricityUnitPrice,
                chargeMode: chargeMode,
                machineAmount: machineAmount,
                paidAmount: paidAmount,
                discountAmount: discountAmount,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnergyRecordRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable:
                                    $$EnergyRecordRowsTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$EnergyRecordRowsTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EnergyRecordRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnergyRecordRowsTable,
      EnergyRecordRow,
      $$EnergyRecordRowsTableFilterComposer,
      $$EnergyRecordRowsTableOrderingComposer,
      $$EnergyRecordRowsTableAnnotationComposer,
      $$EnergyRecordRowsTableCreateCompanionBuilder,
      $$EnergyRecordRowsTableUpdateCompanionBuilder,
      (EnergyRecordRow, $$EnergyRecordRowsTableReferences),
      EnergyRecordRow,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$MaintenanceRecordRowsTableCreateCompanionBuilder =
    MaintenanceRecordRowsCompanion Function({
      required String id,
      required String vehicleId,
      required DateTime date,
      required String category,
      required double cost,
      Value<String> shop,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$MaintenanceRecordRowsTableUpdateCompanionBuilder =
    MaintenanceRecordRowsCompanion Function({
      Value<String> id,
      Value<String> vehicleId,
      Value<DateTime> date,
      Value<String> category,
      Value<double> cost,
      Value<String> shop,
      Value<String> note,
      Value<int> rowid,
    });

final class $$MaintenanceRecordRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceRecordRowsTable,
          MaintenanceRecordRow
        > {
  $$MaintenanceRecordRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehicleRowsTable _vehicleIdTable(_$AppDatabase db) => db.vehicleRows
      .createAlias('maintenance_record_rows__vehicle_id__vehicle_rows__id');

  $$VehicleRowsTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehicleRowsTableTableManager(
      $_db,
      $_db.vehicleRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceRecordRowsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordRowsTable> {
  $$MaintenanceRecordRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shop => $composableBuilder(
    column: $table.shop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$VehicleRowsTableFilterComposer get vehicleId {
    final $$VehicleRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleRowsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRecordRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordRowsTable> {
  $$MaintenanceRecordRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shop => $composableBuilder(
    column: $table.shop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehicleRowsTableOrderingComposer get vehicleId {
    final $$VehicleRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleRowsTableOrderingComposer(
            $db: $db,
            $table: $db.vehicleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRecordRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordRowsTable> {
  $$MaintenanceRecordRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get shop =>
      $composableBuilder(column: $table.shop, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$VehicleRowsTableAnnotationComposer get vehicleId {
    final $$VehicleRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRecordRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceRecordRowsTable,
          MaintenanceRecordRow,
          $$MaintenanceRecordRowsTableFilterComposer,
          $$MaintenanceRecordRowsTableOrderingComposer,
          $$MaintenanceRecordRowsTableAnnotationComposer,
          $$MaintenanceRecordRowsTableCreateCompanionBuilder,
          $$MaintenanceRecordRowsTableUpdateCompanionBuilder,
          (MaintenanceRecordRow, $$MaintenanceRecordRowsTableReferences),
          MaintenanceRecordRow,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$MaintenanceRecordRowsTableTableManager(
    _$AppDatabase db,
    $MaintenanceRecordRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceRecordRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MaintenanceRecordRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaintenanceRecordRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<String> shop = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceRecordRowsCompanion(
                id: id,
                vehicleId: vehicleId,
                date: date,
                category: category,
                cost: cost,
                shop: shop,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vehicleId,
                required DateTime date,
                required String category,
                required double cost,
                Value<String> shop = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceRecordRowsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                date: date,
                category: category,
                cost: cost,
                shop: shop,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceRecordRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable:
                                    $$MaintenanceRecordRowsTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$MaintenanceRecordRowsTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceRecordRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceRecordRowsTable,
      MaintenanceRecordRow,
      $$MaintenanceRecordRowsTableFilterComposer,
      $$MaintenanceRecordRowsTableOrderingComposer,
      $$MaintenanceRecordRowsTableAnnotationComposer,
      $$MaintenanceRecordRowsTableCreateCompanionBuilder,
      $$MaintenanceRecordRowsTableUpdateCompanionBuilder,
      (MaintenanceRecordRow, $$MaintenanceRecordRowsTableReferences),
      MaintenanceRecordRow,
      PrefetchHooks Function({bool vehicleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehicleRowsTableTableManager get vehicleRows =>
      $$VehicleRowsTableTableManager(_db, _db.vehicleRows);
  $$EnergyRecordRowsTableTableManager get energyRecordRows =>
      $$EnergyRecordRowsTableTableManager(_db, _db.energyRecordRows);
  $$MaintenanceRecordRowsTableTableManager get maintenanceRecordRows =>
      $$MaintenanceRecordRowsTableTableManager(_db, _db.maintenanceRecordRows);
}
