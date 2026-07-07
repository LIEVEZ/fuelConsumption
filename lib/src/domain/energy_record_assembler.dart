import 'package:fuel_consumption/src/domain/models.dart';

class ChargeRecordDraft {
  const ChargeRecordDraft({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometerText,
    required this.kwhText,
    required this.unitPriceText,
    required this.chargeMode,
    required this.noteText,
  });

  final String id;
  final String vehicleId;
  final DateTime date;
  final String odometerText;
  final String kwhText;
  final String unitPriceText;
  final ChargeMode chargeMode;
  final String noteText;
}

class HybridRecordDraft {
  const HybridRecordDraft({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.odometerText,
    required this.litersText,
    required this.fuelUnitPriceText,
    required this.kwhText,
    required this.electricityUnitPriceText,
    required this.noteText,
  });

  final String id;
  final String vehicleId;
  final DateTime date;
  final String odometerText;
  final String litersText;
  final String fuelUnitPriceText;
  final String kwhText;
  final String electricityUnitPriceText;
  final String noteText;
}

class EnergyRecordAssembler {
  const EnergyRecordAssembler._();

  static EnergyRecordAssemblyResult assembleCharge(ChargeRecordDraft draft) {
    final odometer = double.tryParse(draft.odometerText);
    final kwh = double.tryParse(draft.kwhText);
    final unitPrice = double.tryParse(draft.unitPriceText);

    if (odometer == null) {
      return const EnergyRecordAssemblyResult.failure('请填写当前里程');
    }
    if (kwh == null || kwh <= 0) {
      return const EnergyRecordAssemblyResult.failure('请填写有效充电电量');
    }
    if (unitPrice == null || unitPrice <= 0) {
      return const EnergyRecordAssemblyResult.failure('请填写有效充电单价');
    }

    return EnergyRecordAssemblyResult.success(
      EnergyRecord.charge(
        id: draft.id,
        vehicleId: draft.vehicleId,
        date: draft.date,
        odometerKm: odometer,
        kwh: kwh,
        unitPrice: unitPrice,
        chargeMode: draft.chargeMode,
        note: draft.noteText.trim(),
      ),
    );
  }

  static EnergyRecordAssemblyResult assembleHybrid(HybridRecordDraft draft) {
    final odometer = double.tryParse(draft.odometerText);
    final liters = double.tryParse(draft.litersText) ?? 0;
    final fuelUnitPrice = double.tryParse(draft.fuelUnitPriceText) ?? 0;
    final kwh = double.tryParse(draft.kwhText) ?? 0;
    final electricityUnitPrice =
        double.tryParse(draft.electricityUnitPriceText) ?? 0;

    if (odometer == null) {
      return const EnergyRecordAssemblyResult.failure('请填写当前里程');
    }
    if (liters <= 0 && kwh <= 0) {
      return const EnergyRecordAssemblyResult.failure('请至少填写燃油或电量');
    }
    if ((liters > 0 && fuelUnitPrice <= 0) ||
        (kwh > 0 && electricityUnitPrice <= 0)) {
      return const EnergyRecordAssemblyResult.failure('请填写有效单价');
    }

    return EnergyRecordAssemblyResult.success(
      EnergyRecord.hybrid(
        id: draft.id,
        vehicleId: draft.vehicleId,
        date: draft.date,
        odometerKm: odometer,
        liters: liters,
        fuelUnitPrice: fuelUnitPrice,
        kwh: kwh,
        electricityUnitPrice: electricityUnitPrice,
        note: draft.noteText.trim(),
      ),
    );
  }
}

class EnergyRecordAssemblyResult {
  const EnergyRecordAssemblyResult._({this.record, this.error});

  const EnergyRecordAssemblyResult.success(EnergyRecord record)
    : this._(record: record);

  const EnergyRecordAssemblyResult.failure(String error) : this._(error: error);

  final EnergyRecord? record;
  final String? error;

  bool get isSuccess => record != null;
}
