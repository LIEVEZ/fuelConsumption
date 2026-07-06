import 'package:flutter/widgets.dart';
import 'package:fuel_consumption/src/domain/refuel_amount_calculator.dart';
import 'package:fuel_consumption/src/domain/refuel_record_assembler.dart';

class RefuelFormController extends ChangeNotifier {
  RefuelFormController({required double initialOdometerKm}) {
    odometerController.text = initialOdometerKm.toStringAsFixed(0);
    unitPriceController.addListener(
      () => _onMachineFieldChanged(RefuelMachineField.unitPrice),
    );
    litersController.addListener(
      () => _onMachineFieldChanged(RefuelMachineField.liters),
    );
    machineAmountController.addListener(
      () => _onMachineFieldChanged(RefuelMachineField.amount),
    );
    discountController.addListener(
      () => _onPaymentFieldChanged(RefuelPaymentField.discount),
    );
    paidAmountController.addListener(
      () => _onPaymentFieldChanged(RefuelPaymentField.paidAmount),
    );
    paidUnitPriceController.addListener(
      () => _onPaymentFieldChanged(RefuelPaymentField.paidUnitPrice),
    );
    odometerController.addListener(notifyListeners);
  }

  final odometerController = TextEditingController();
  final unitPriceController = TextEditingController(text: '7.25');
  final litersController = TextEditingController(text: '0.00');
  final machineAmountController = TextEditingController(text: '0.00');
  final paidUnitPriceController = TextEditingController(text: '0.00');
  final discountController = TextEditingController(text: '0.00');
  final paidAmountController = TextEditingController(text: '0.00');
  final noteController = TextEditingController();

  bool _syncingAmounts = false;
  RefuelMachineField _lastMachineField = RefuelMachineField.unitPrice;
  RefuelPaymentField _lastPaymentField = RefuelPaymentField.discount;

  RefuelAmountValues get amountValues {
    final unitPrice = _parseAmount(unitPriceController);
    final liters = _parseAmount(litersController);
    final machineAmount =
        double.tryParse(machineAmountController.text) ?? unitPrice * liters;
    final paidAmount =
        double.tryParse(paidAmountController.text) ??
        RefuelAmountCalculator.paidAmountFromDiscount(machineAmount, _discount);
    return RefuelAmountValues(
      unitPrice: unitPrice,
      liters: liters,
      machineAmount: machineAmount,
      paidUnitPrice: _parseAmount(paidUnitPriceController),
      discount: _discount,
      paidAmount: paidAmount,
    );
  }

  RefuelRecordDraft buildDraft({
    required String id,
    required String vehicleId,
    required DateTime date,
    required bool isFull,
    required bool warningLightOn,
    required String fuelGrade,
  }) {
    return RefuelRecordDraft(
      id: id,
      vehicleId: vehicleId,
      date: date,
      odometerText: odometerController.text,
      unitPriceText: unitPriceController.text,
      litersText: litersController.text,
      machineAmountText: machineAmountController.text,
      paidUnitPriceText: paidUnitPriceController.text,
      discountText: discountController.text,
      paidAmountText: paidAmountController.text,
      isFull: isFull,
      warningLightOn: warningLightOn,
      fuelGrade: fuelGrade,
      noteText: noteController.text,
    );
  }

  double get _discount => double.tryParse(discountController.text) ?? 0;

  double _parseAmount(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0;
  }

  void _onMachineFieldChanged(RefuelMachineField field) {
    if (_syncingAmounts) return;
    _lastMachineField = field;
    _syncMachineFields();
  }

  void _onPaymentFieldChanged(RefuelPaymentField field) {
    if (_syncingAmounts) return;
    _lastPaymentField = field;
    _syncPaymentFields();
  }

  void _syncMachineFields() {
    _syncingAmounts = true;
    final values = RefuelAmountCalculator.syncMachineFields(
      amountValues,
      _lastMachineField,
    );
    _applyMachineValues(values);
    _syncingAmounts = false;
    _syncPaymentFields();
  }

  void _syncPaymentFields() {
    if (_syncingAmounts) return;
    _syncingAmounts = true;
    final values = RefuelAmountCalculator.syncPaymentFields(
      amountValues,
      _lastPaymentField,
    );
    _applyPaymentValues(values);
    _syncingAmounts = false;
    notifyListeners();
  }

  void _applyMachineValues(RefuelAmountValues values) {
    switch (_lastMachineField) {
      case RefuelMachineField.unitPrice:
        _setControllerText(
          litersController,
          RefuelAmountCalculator.formatAmount(values.liters),
        );
        _setControllerText(
          machineAmountController,
          RefuelAmountCalculator.formatAmount(values.machineAmount),
        );
      case RefuelMachineField.liters:
        _setControllerText(
          unitPriceController,
          RefuelAmountCalculator.formatAmount(values.unitPrice),
        );
        _setControllerText(
          machineAmountController,
          RefuelAmountCalculator.formatAmount(values.machineAmount),
        );
      case RefuelMachineField.amount:
        _setControllerText(
          unitPriceController,
          RefuelAmountCalculator.formatAmount(values.unitPrice),
        );
        _setControllerText(
          litersController,
          RefuelAmountCalculator.formatAmount(values.liters),
        );
    }
  }

  void _applyPaymentValues(RefuelAmountValues values) {
    switch (_lastPaymentField) {
      case RefuelPaymentField.discount:
        _setControllerText(
          paidUnitPriceController,
          RefuelAmountCalculator.formatAmount(values.paidUnitPrice),
        );
        _setControllerText(
          paidAmountController,
          RefuelAmountCalculator.formatAmount(values.paidAmount),
        );
      case RefuelPaymentField.paidAmount:
        _setControllerText(
          paidUnitPriceController,
          RefuelAmountCalculator.formatAmount(values.paidUnitPrice),
        );
        _setControllerText(
          discountController,
          RefuelAmountCalculator.formatAmount(values.discount),
        );
      case RefuelPaymentField.paidUnitPrice:
        _setControllerText(
          discountController,
          RefuelAmountCalculator.formatAmount(values.discount),
        );
        _setControllerText(
          paidAmountController,
          RefuelAmountCalculator.formatAmount(values.paidAmount),
        );
    }
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  void dispose() {
    odometerController.dispose();
    unitPriceController.dispose();
    litersController.dispose();
    machineAmountController.dispose();
    paidUnitPriceController.dispose();
    discountController.dispose();
    paidAmountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
