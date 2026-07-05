import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/fuel_grades.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/refuel_amount_calculator.dart';
import 'package:fuel_consumption/src/domain/refuel_record_assembler.dart';
import 'package:fuel_consumption/src/domain/validation.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/refuel/refuel_form_widgets.dart';
import 'package:uuid/uuid.dart';

class RefuelScreen extends StatefulWidget {
  const RefuelScreen({
    required this.vehicle,
    required this.records,
    required this.onSave,
    required this.onSaved,
    super.key,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final Future<void> Function(EnergyRecord record) onSave;
  final VoidCallback onSaved;

  @override
  State<RefuelScreen> createState() => _RefuelScreenState();
}

class _RefuelScreenState extends State<RefuelScreen> {
  final _odometerController = TextEditingController();
  final _unitPriceController = TextEditingController(text: '7.25');
  final _litersController = TextEditingController(text: '0.00');
  final _machineAmountController = TextEditingController(text: '0.00');
  final _paidUnitPriceController = TextEditingController(text: '0.00');
  final _discountController = TextEditingController(text: '0.00');
  final _paidAmountController = TextEditingController(text: '0.00');
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isFull = true;
  bool _warningLightOn = false;
  bool _saving = false;
  String _fuelGrade = defaultFuelGrade;
  bool _syncingAmounts = false;
  RefuelMachineField _lastMachineField = RefuelMachineField.unitPrice;
  RefuelPaymentField _lastPaymentField = RefuelPaymentField.discount;
  String? _error;

  double get _discount => double.tryParse(_discountController.text) ?? 0;

  @override
  void initState() {
    super.initState();
    final latest = widget.records.isEmpty
        ? widget.vehicle.initialOdometerKm
        : widget.records.last.odometerKm;
    _odometerController.text = latest.toStringAsFixed(0);
    _unitPriceController.addListener(
      () => _onMachineFieldChanged(RefuelMachineField.unitPrice),
    );
    _litersController.addListener(
      () => _onMachineFieldChanged(RefuelMachineField.liters),
    );
    _machineAmountController.addListener(
      () => _onMachineFieldChanged(RefuelMachineField.amount),
    );
    _discountController.addListener(
      () => _onPaymentFieldChanged(RefuelPaymentField.discount),
    );
    _paidAmountController.addListener(
      () => _onPaymentFieldChanged(RefuelPaymentField.paidAmount),
    );
    _paidUnitPriceController.addListener(
      () => _onPaymentFieldChanged(RefuelPaymentField.paidUnitPrice),
    );
    _odometerController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _unitPriceController.dispose();
    _litersController.dispose();
    _machineAmountController.dispose();
    _paidUnitPriceController.dispose();
    _discountController.dispose();
    _paidAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
      children: [
        RefuelFormSection(
          children: [
            RefuelValueRow(
              label: '加油日期',
              required: true,
              value: shortDate(_date),
              onTap: _pickDate,
            ),
            RefuelValueRow(
              label: '加油时间',
              required: true,
              value: shortTime(_date),
              onTap: _pickTime,
            ),
            RefuelInputRow(
              label: '当前里程',
              required: true,
              controller: _odometerController,
              suffix: '公里',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              child: Text(
                '机显单价（元/升） × 加油量（升） = 机显金额（元）',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Row(
                children: [
                  Expanded(
                    child: RefuelCompactInput(controller: _unitPriceController),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelCompactInput(controller: _litersController),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelCompactInput(
                      controller: _machineAmountController,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: RefuelFieldColumn(
                      label: '实付单价',
                      child: RefuelCompactInput(
                        controller: _paidUnitPriceController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelFieldColumn(
                      label: '优惠金额',
                      child: RefuelCompactInput(
                        controller: _discountController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelFieldColumn(
                      label: '实付金额',
                      child: RefuelCompactInput(
                        controller: _paidAmountController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            RefuelSegmentRow(
              label: '是否加满跳枪？',
              leftLabel: '已跳枪',
              rightLabel: '未跳枪',
              selectedRight: !_isFull,
              onChanged: (right) => setState(() => _isFull = !right),
            ),
            RefuelSegmentRow(
              label: '油量警告灯亮了吗？',
              leftLabel: '油灯亮',
              rightLabel: '没有亮',
              selectedRight: !_warningLightOn,
              onChanged: (right) => setState(() => _warningLightOn = !right),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42),
          child: SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sky,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RefuelOptionalSection(
            fuelGrade: _fuelGrade,
            onFuelGradeTap: _pickFuelGrade,
          ),
        ),
      ],
    );
  }

  RefuelAmountValues get _amountValues {
    final unitPrice = _parseAmount(_unitPriceController);
    final liters = _parseAmount(_litersController);
    final machineAmount =
        double.tryParse(_machineAmountController.text) ?? unitPrice * liters;
    final paidAmount =
        double.tryParse(_paidAmountController.text) ??
        RefuelAmountCalculator.paidAmountFromDiscount(machineAmount, _discount);
    return RefuelAmountValues(
      unitPrice: unitPrice,
      liters: liters,
      machineAmount: machineAmount,
      paidUnitPrice: _parseAmount(_paidUnitPriceController),
      discount: _discount,
      paidAmount: paidAmount,
    );
  }

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
      _amountValues,
      _lastMachineField,
    );
    _applyMachineValues(values);
    _syncingAmounts = false;
    _syncPaymentFields();
    setState(() {});
  }

  void _syncPaymentFields() {
    if (_syncingAmounts) {
      return;
    }
    _syncingAmounts = true;
    final values = RefuelAmountCalculator.syncPaymentFields(
      _amountValues,
      _lastPaymentField,
    );
    _applyPaymentValues(values);
    _syncingAmounts = false;
    setState(() {});
  }

  void _applyMachineValues(RefuelAmountValues values) {
    switch (_lastMachineField) {
      case RefuelMachineField.unitPrice:
        _setControllerText(
          _litersController,
          RefuelAmountCalculator.formatAmount(values.liters),
        );
        _setControllerText(
          _machineAmountController,
          RefuelAmountCalculator.formatAmount(values.machineAmount),
        );
      case RefuelMachineField.liters:
        _setControllerText(
          _unitPriceController,
          RefuelAmountCalculator.formatAmount(values.unitPrice),
        );
        _setControllerText(
          _machineAmountController,
          RefuelAmountCalculator.formatAmount(values.machineAmount),
        );
      case RefuelMachineField.amount:
        _setControllerText(
          _unitPriceController,
          RefuelAmountCalculator.formatAmount(values.unitPrice),
        );
        _setControllerText(
          _litersController,
          RefuelAmountCalculator.formatAmount(values.liters),
        );
    }
  }

  void _applyPaymentValues(RefuelAmountValues values) {
    switch (_lastPaymentField) {
      case RefuelPaymentField.discount:
        _setControllerText(
          _paidUnitPriceController,
          RefuelAmountCalculator.formatAmount(values.paidUnitPrice),
        );
        _setControllerText(
          _paidAmountController,
          RefuelAmountCalculator.formatAmount(values.paidAmount),
        );
      case RefuelPaymentField.paidAmount:
        _setControllerText(
          _paidUnitPriceController,
          RefuelAmountCalculator.formatAmount(values.paidUnitPrice),
        );
        _setControllerText(
          _discountController,
          RefuelAmountCalculator.formatAmount(values.discount),
        );
      case RefuelPaymentField.paidUnitPrice:
        _setControllerText(
          _discountController,
          RefuelAmountCalculator.formatAmount(values.discount),
        );
        _setControllerText(
          _paidAmountController,
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = DateTime(
        _date.year,
        _date.month,
        _date.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _pickFuelGrade() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            for (final grade in fuelGrades)
              ListTile(
                title: Text(grade),
                trailing: grade == _fuelGrade
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(grade),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _fuelGrade = selected);
  }

  Future<void> _save() async {
    final assembly = RefuelRecordAssembler.assemble(
      RefuelRecordDraft(
        id: const Uuid().v4(),
        vehicleId: widget.vehicle.id,
        date: _date,
        odometerText: _odometerController.text,
        unitPriceText: _unitPriceController.text,
        litersText: _litersController.text,
        machineAmountText: _machineAmountController.text,
        paidUnitPriceText: _paidUnitPriceController.text,
        discountText: _discountController.text,
        paidAmountText: _paidAmountController.text,
        isFull: _isFull,
        warningLightOn: _warningLightOn,
        fuelGrade: _fuelGrade,
        noteText: _noteController.text,
      ),
    );
    if (!assembly.isSuccess) {
      setState(() => _error = assembly.error);
      return;
    }
    final record = assembly.record!;
    final validation = RecordValidator().validate(record, widget.records);
    if (!validation.isValid) {
      setState(() => _error = validation.message);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(record);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存加油记录')));
      widget.onSaved();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
