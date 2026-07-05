import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/validation.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';
import 'package:uuid/uuid.dart';

enum _MachineField { unitPrice, liters, amount }

enum _PaymentField { paidUnitPrice, discount, paidAmount }

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
  String _fuelGrade = '92#汽油';
  bool _syncingAmounts = false;
  _MachineField _lastMachineField = _MachineField.unitPrice;
  _PaymentField _lastPaymentField = _PaymentField.discount;
  String? _error;

  double get _unitPrice => double.tryParse(_unitPriceController.text) ?? 0;
  double get _liters => double.tryParse(_litersController.text) ?? 0;
  double get _paidUnitPrice =>
      double.tryParse(_paidUnitPriceController.text) ?? 0;
  double get _discount => double.tryParse(_discountController.text) ?? 0;
  double get _machineAmount =>
      double.tryParse(_machineAmountController.text) ?? _unitPrice * _liters;
  double get _paidAmount =>
      double.tryParse(_paidAmountController.text) ??
      (_machineAmount - _discount).clamp(0, double.infinity).toDouble();

  @override
  void initState() {
    super.initState();
    final latest = widget.records.isEmpty
        ? widget.vehicle.initialOdometerKm
        : widget.records.last.odometerKm;
    _odometerController.text = latest.toStringAsFixed(0);
    _unitPriceController.addListener(
      () => _onMachineFieldChanged(_MachineField.unitPrice),
    );
    _litersController.addListener(
      () => _onMachineFieldChanged(_MachineField.liters),
    );
    _machineAmountController.addListener(
      () => _onMachineFieldChanged(_MachineField.amount),
    );
    _discountController.addListener(
      () => _onPaymentFieldChanged(_PaymentField.discount),
    );
    _paidAmountController.addListener(
      () => _onPaymentFieldChanged(_PaymentField.paidAmount),
    );
    _paidUnitPriceController.addListener(
      () => _onPaymentFieldChanged(_PaymentField.paidUnitPrice),
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
        _FormSection(
          children: [
            _ValueRow(
              label: '加油日期',
              required: true,
              value: shortDate(_date),
              onTap: _pickDate,
            ),
            _ValueRow(
              label: '加油时间',
              required: true,
              value: shortTime(_date),
              onTap: _pickTime,
            ),
            _InputRow(
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
                    child: _CompactInput(controller: _unitPriceController),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _CompactInput(controller: _litersController)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CompactInput(controller: _machineAmountController),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _FieldColumn(
                      label: '实付单价',
                      child: _CompactInput(
                        controller: _paidUnitPriceController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FieldColumn(
                      label: '优惠金额',
                      child: _CompactInput(controller: _discountController),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FieldColumn(
                      label: '实付金额',
                      child: _CompactInput(controller: _paidAmountController),
                    ),
                  ),
                ],
              ),
            ),
            _SegmentRow(
              label: '是否加满跳枪？',
              leftLabel: '已跳枪',
              rightLabel: '未跳枪',
              selectedRight: !_isFull,
              onChanged: (right) => setState(() => _isFull = !right),
            ),
            _SegmentRow(
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
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sky,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text(
                '保存',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
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
          child: _OptionalSection(
            fuelGrade: _fuelGrade,
            onFuelGradeTap: _pickFuelGrade,
          ),
        ),
      ],
    );
  }

  void _onMachineFieldChanged(_MachineField field) {
    if (_syncingAmounts) return;
    _lastMachineField = field;
    _syncMachineFields();
  }

  void _onPaymentFieldChanged(_PaymentField field) {
    if (_syncingAmounts) return;
    _lastPaymentField = field;
    _syncPaymentFields();
  }

  void _syncMachineFields() {
    _syncingAmounts = true;
    switch (_lastMachineField) {
      case _MachineField.unitPrice:
        if (_unitPrice > 0 && _liters > 0) {
          _setControllerText(
            _machineAmountController,
            _formatAmount(_unitPrice * _liters),
          );
        } else if (_unitPrice > 0 && _machineAmount > 0) {
          _setControllerText(
            _litersController,
            _formatAmount(_machineAmount / _unitPrice),
          );
        }
      case _MachineField.liters:
        if (_unitPrice > 0 && _liters > 0) {
          _setControllerText(
            _machineAmountController,
            _formatAmount(_unitPrice * _liters),
          );
        } else if (_liters > 0 && _machineAmount > 0) {
          _setControllerText(
            _unitPriceController,
            _formatAmount(_machineAmount / _liters),
          );
        }
      case _MachineField.amount:
        if (_unitPrice > 0 && _machineAmount > 0) {
          _setControllerText(
            _litersController,
            _formatAmount(_machineAmount / _unitPrice),
          );
        } else if (_liters > 0 && _machineAmount > 0) {
          _setControllerText(
            _unitPriceController,
            _formatAmount(_machineAmount / _liters),
          );
        }
    }
    _syncingAmounts = false;
    _syncPaymentFields();
    setState(() {});
  }

  void _syncPaymentFields() {
    if (_syncingAmounts) {
      return;
    }
    _syncingAmounts = true;
    switch (_lastPaymentField) {
      case _PaymentField.discount:
        final paidAmount = (_machineAmount - _discount)
            .clamp(0, double.infinity)
            .toDouble();
        _setControllerText(_paidAmountController, _formatAmount(paidAmount));
        if (_liters > 0) {
          _setControllerText(
            _paidUnitPriceController,
            _formatAmount(paidAmount / _liters),
          );
        }
      case _PaymentField.paidAmount:
        final discount = (_machineAmount - _paidAmount)
            .clamp(0, double.infinity)
            .toDouble();
        _setControllerText(_discountController, _formatAmount(discount));
        if (_liters > 0) {
          _setControllerText(
            _paidUnitPriceController,
            _formatAmount(_paidAmount / _liters),
          );
        }
      case _PaymentField.paidUnitPrice:
        if (_paidUnitPrice > 0 && _liters > 0) {
          final paidAmount = _paidUnitPrice * _liters;
          _setControllerText(_paidAmountController, _formatAmount(paidAmount));
          final discount = (_machineAmount - paidAmount)
              .clamp(0, double.infinity)
              .toDouble();
          _setControllerText(_discountController, _formatAmount(discount));
        }
    }
    _syncingAmounts = false;
    setState(() {});
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _formatAmount(double value) {
    if (value == 0) return '0.00';
    return value.toStringAsFixed(2);
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
            for (final grade in _fuelGrades)
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
    final odometer = double.tryParse(_odometerController.text);
    final inputLiters = double.tryParse(_litersController.text);
    final inputUnitPrice = double.tryParse(_unitPriceController.text);
    final inputMachineAmount = double.tryParse(_machineAmountController.text);
    final inputPaidUnitPrice = double.tryParse(_paidUnitPriceController.text);
    final inputPaidAmount = double.tryParse(_paidAmountController.text);
    if (odometer == null) {
      setState(() => _error = '请填写当前里程');
      return;
    }

    final machineAmount =
        inputMachineAmount ?? ((inputUnitPrice ?? 0) * (inputLiters ?? 0));
    final paidAmount =
        inputPaidAmount ??
        (machineAmount - _discount).clamp(0, double.infinity).toDouble();
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
      setState(() => _error = '请填写加油量，或填写单价和机显金额');
      return;
    }
    if (liters <= 0 || effectiveUnitPrice <= 0 || paidAmount <= 0) {
      setState(() => _error = '加油量、实付金额必须大于 0');
      return;
    }

    final note = [
      if (_warningLightOn) '油灯亮',
      if (inputUnitPrice != null)
        '机显单价 ${inputUnitPrice.toStringAsFixed(2)} 元/升',
      if (machineAmount > 0) '机显金额 ${machineAmount.toStringAsFixed(2)} 元',
      if (_discount > 0) '优惠 ${_discount.toStringAsFixed(2)} 元',
      if (paidAmount > 0) '实付金额 ${paidAmount.toStringAsFixed(2)} 元',
      _fuelGrade,
      _noteController.text.trim(),
    ].where((item) => item.isNotEmpty).join(' · ');
    final record = EnergyRecord.fuel(
      id: const Uuid().v4(),
      vehicleId: widget.vehicle.id,
      date: _date,
      odometerKm: odometer,
      liters: liters,
      unitPrice: effectiveUnitPrice,
      isFull: _isFull,
      note: note,
    );
    final validation = RecordValidator().validate(record, widget.records);
    if (!validation.isValid) {
      setState(() => _error = validation.message);
      return;
    }

    await widget.onSave(record);
    if (!mounted) return;
    setState(() => _error = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已保存加油记录')));
    widget.onSaved();
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(children: children),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.required = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      title: _RequiredLabel(label: label, required: required),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const Icon(Icons.chevron_right, size: 32),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.label,
    required this.controller,
    this.suffix,
    this.required = false,
  });

  final String label;
  final TextEditingController controller;
  final String? suffix;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _RequiredLabel(label: label, required: required),
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(suffixText: suffix),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: AppColors.danger)),
      ],
    );
  }
}

class _CompactInput extends StatelessWidget {
  const _CompactInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onTap: () {
        if (controller.text == '0.00') {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      },
      decoration: const InputDecoration(contentPadding: EdgeInsets.all(16)),
    );
  }
}

class _FieldColumn extends StatelessWidget {
  const _FieldColumn({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.label,
    required this.leftLabel,
    required this.rightLabel,
    required this.selectedRight,
    required this.onChanged,
  });

  final String label;
  final String leftLabel;
  final String rightLabel;
  final bool selectedRight;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          _SegmentButton(
            label: leftLabel,
            selected: !selectedRight,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 8),
          _SegmentButton(
            label: rightLabel,
            selected: selectedRight,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        width: 90,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.sky : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _OptionalSection extends StatelessWidget {
  const _OptionalSection({
    required this.fuelGrade,
    required this.onFuelGradeTap,
  });

  final String fuelGrade;
  final VoidCallback onFuelGradeTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SectionHeader(title: '选填项'),
            const SizedBox(height: 16),
            const _OptionTile(label: '加油站', value: ''),
            const Divider(height: 1),
            _OptionTile(label: '燃油标号', value: fuelGrade, onTap: onFuelGradeTap),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty) Text(value),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

const _fuelGrades = [
  '89#汽油',
  '92#汽油',
  '95#汽油',
  '98#汽油',
  '0#柴油',
  '-10#柴油',
  '-20#柴油',
  '-35#柴油',
];
