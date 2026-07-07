import 'package:fuel_consumption/src/application/ports/app_repository.dart';
import 'package:fuel_consumption/src/domain/energy_record_assembler.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/refuel_record_assembler.dart';
import 'package:fuel_consumption/src/domain/validation.dart';
import 'package:uuid/uuid.dart';

class RefuelRecordInput {
  const RefuelRecordInput({
    required this.vehicleId,
    required this.date,
    required this.odometerText,
    required this.unitPriceText,
    required this.litersText,
    required this.machineAmountText,
    required this.paidUnitPriceText,
    required this.discountText,
    required this.paidAmountText,
    required this.isFull,
    required this.warningLightOn,
    required this.fuelGrade,
    required this.noteText,
  });

  final String vehicleId;
  final DateTime date;
  final String odometerText;
  final String unitPriceText;
  final String litersText;
  final String machineAmountText;
  final String paidUnitPriceText;
  final String discountText;
  final String paidAmountText;
  final bool isFull;
  final bool warningLightOn;
  final String fuelGrade;
  final String noteText;
}

class ChargeRecordInput {
  const ChargeRecordInput({
    required this.vehicleId,
    required this.date,
    required this.odometerText,
    required this.kwhText,
    required this.unitPriceText,
    required this.chargeMode,
    required this.noteText,
  });

  final String vehicleId;
  final DateTime date;
  final String odometerText;
  final String kwhText;
  final String unitPriceText;
  final ChargeMode chargeMode;
  final String noteText;
}

class HybridRecordInput {
  const HybridRecordInput({
    required this.vehicleId,
    required this.date,
    required this.odometerText,
    required this.litersText,
    required this.fuelUnitPriceText,
    required this.kwhText,
    required this.electricityUnitPriceText,
    required this.noteText,
  });

  final String vehicleId;
  final DateTime date;
  final String odometerText;
  final String litersText;
  final String fuelUnitPriceText;
  final String kwhText;
  final String electricityUnitPriceText;
  final String noteText;
}

class MaintenanceRecordInput {
  const MaintenanceRecordInput({
    required this.vehicleId,
    required this.date,
    required this.category,
    required this.costText,
    required this.shopText,
    required this.noteText,
  });

  final String vehicleId;
  final DateTime date;
  final MaintenanceCategory category;
  final String costText;
  final String shopText;
  final String noteText;
}

class RecordCommandService {
  RecordCommandService({
    required AppRepository repository,
    String Function()? generateId,
  }) : _repository = repository,
       _generateId = generateId ?? const Uuid().v4;

  final AppRepository _repository;
  final String Function() _generateId;

  Future<EnergyRecord> saveRefuel(RefuelRecordInput input) {
    final assembly = RefuelRecordAssembler.assemble(
      RefuelRecordDraft(
        id: _generateId(),
        vehicleId: input.vehicleId,
        date: input.date,
        odometerText: input.odometerText,
        unitPriceText: input.unitPriceText,
        litersText: input.litersText,
        machineAmountText: input.machineAmountText,
        paidUnitPriceText: input.paidUnitPriceText,
        discountText: input.discountText,
        paidAmountText: input.paidAmountText,
        isFull: input.isFull,
        warningLightOn: input.warningLightOn,
        fuelGrade: input.fuelGrade,
        noteText: input.noteText,
      ),
    );
    return _saveAssembledRecord(assembly);
  }

  Future<EnergyRecord> saveCharge(ChargeRecordInput input) {
    final assembly = EnergyRecordAssembler.assembleCharge(
      ChargeRecordDraft(
        id: _generateId(),
        vehicleId: input.vehicleId,
        date: input.date,
        odometerText: input.odometerText,
        kwhText: input.kwhText,
        unitPriceText: input.unitPriceText,
        chargeMode: input.chargeMode,
        noteText: input.noteText,
      ),
    );
    return _saveAssembledRecord(assembly);
  }

  Future<EnergyRecord> saveHybrid(HybridRecordInput input) {
    final assembly = EnergyRecordAssembler.assembleHybrid(
      HybridRecordDraft(
        id: _generateId(),
        vehicleId: input.vehicleId,
        date: input.date,
        odometerText: input.odometerText,
        litersText: input.litersText,
        fuelUnitPriceText: input.fuelUnitPriceText,
        kwhText: input.kwhText,
        electricityUnitPriceText: input.electricityUnitPriceText,
        noteText: input.noteText,
      ),
    );
    return _saveAssembledRecord(assembly);
  }

  Future<MaintenanceRecord> saveMaintenance(
    MaintenanceRecordInput input,
  ) async {
    final cost = double.tryParse(input.costText);
    if (cost == null || cost <= 0) {
      throw const FormatException('请填写有效保养费用');
    }

    final record = MaintenanceRecord(
      id: _generateId(),
      vehicleId: input.vehicleId,
      date: input.date,
      category: input.category,
      cost: cost,
      shop: input.shopText.trim(),
      note: input.noteText.trim(),
    );
    final validation = MaintenanceRecordValidator().validate(record);
    if (!validation.isValid) {
      throw FormatException(validation.message);
    }
    await _repository.saveMaintenanceRecord(record);
    return record;
  }

  Future<EnergyRecord> _saveAssembledRecord(Object assembly) async {
    final record = switch (assembly) {
      RefuelRecordAssemblyResult result when result.isSuccess => result.record!,
      RefuelRecordAssemblyResult result => throw FormatException(result.error!),
      EnergyRecordAssemblyResult result when result.isSuccess => result.record!,
      EnergyRecordAssemblyResult result => throw FormatException(result.error!),
      _ => throw ArgumentError.value(assembly, 'assembly'),
    };
    final previousRecords = await _repository.getRecords(record.vehicleId);
    final validation = RecordValidator().validate(record, previousRecords);
    if (!validation.isValid) {
      throw FormatException(validation.message);
    }
    await _repository.saveRecord(record);
    return record;
  }
}
