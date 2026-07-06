import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/refuel_amount_calculator.dart';

class RefuelRecordDraft {
  const RefuelRecordDraft({
    required this.id,
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

  final String id;
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

class RefuelRecordAssembler {
  const RefuelRecordAssembler._();

  static RefuelRecordAssemblyResult assemble(RefuelRecordDraft draft) {
    final odometer = double.tryParse(draft.odometerText);
    final inputLiters = double.tryParse(draft.litersText);
    final inputUnitPrice = double.tryParse(draft.unitPriceText);
    final inputMachineAmount = double.tryParse(draft.machineAmountText);
    final inputPaidUnitPrice = double.tryParse(draft.paidUnitPriceText);
    final inputDiscount = double.tryParse(draft.discountText) ?? 0;
    final inputPaidAmount = double.tryParse(draft.paidAmountText);

    if (odometer == null) {
      return const RefuelRecordAssemblyResult.failure('请填写当前里程');
    }

    final machineAmount =
        inputMachineAmount ?? ((inputUnitPrice ?? 0) * (inputLiters ?? 0));
    final paidAmount =
        inputPaidAmount ??
        RefuelAmountCalculator.paidAmountFromDiscount(
          machineAmount,
          inputDiscount,
        );
    final liters =
        inputLiters ??
        ((inputUnitPrice != null && inputUnitPrice > 0 && machineAmount > 0)
            ? machineAmount / inputUnitPrice
            : null);
    final effectiveUnitPrice =
        inputPaidUnitPrice ??
        ((liters != null && liters > 0 && paidAmount > 0)
            ? paidAmount / liters
            : inputUnitPrice);

    if (liters == null || effectiveUnitPrice == null) {
      return const RefuelRecordAssemblyResult.failure('请填写加油量，或填写单价和机显金额');
    }
    if (liters <= 0 || effectiveUnitPrice <= 0 || paidAmount <= 0) {
      return const RefuelRecordAssemblyResult.failure('加油量、实付金额必须大于 0');
    }
    final discountAmount = RefuelAmountCalculator.paidAmountFromDiscount(
      machineAmount,
      paidAmount,
    );

    final note = [
      if (draft.warningLightOn) '油灯亮',
      if (inputUnitPrice != null)
        '机显单价 ${inputUnitPrice.toStringAsFixed(2)} 元/升',
      if (machineAmount > 0) '机显金额 ${machineAmount.toStringAsFixed(2)} 元',
      if (inputDiscount > 0) '优惠 ${inputDiscount.toStringAsFixed(2)} 元',
      if (paidAmount > 0) '实付金额 ${paidAmount.toStringAsFixed(2)} 元',
      draft.fuelGrade,
      draft.noteText.trim(),
    ].where((item) => item.isNotEmpty).join(' · ');

    return RefuelRecordAssemblyResult.success(
      EnergyRecord.fuel(
        id: draft.id,
        vehicleId: draft.vehicleId,
        date: draft.date,
        odometerKm: odometer,
        liters: liters,
        unitPrice: effectiveUnitPrice,
        isFull: draft.isFull,
        machineAmount: machineAmount,
        paidAmount: paidAmount,
        discountAmount: discountAmount,
        note: note,
      ),
    );
  }
}

class RefuelRecordAssemblyResult {
  const RefuelRecordAssemblyResult._({this.record, this.error});

  const RefuelRecordAssemblyResult.success(EnergyRecord record)
    : this._(record: record);

  const RefuelRecordAssemblyResult.failure(String error) : this._(error: error);

  final EnergyRecord? record;
  final String? error;

  bool get isSuccess => record != null;
}
