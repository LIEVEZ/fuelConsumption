import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/fuel_grades.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/refuel_record_assembler.dart';
import 'package:fuel_consumption/src/domain/validation.dart';
import 'package:fuel_consumption/src/screens/refuel_form_controller.dart';
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
  late final RefuelFormController _form;
  DateTime _date = DateTime.now();
  bool _isFull = true;
  bool _warningLightOn = false;
  bool _saving = false;
  String _fuelGrade = defaultFuelGrade;
  String? _error;

  @override
  void initState() {
    super.initState();
    final latest = widget.records.isEmpty
        ? widget.vehicle.initialOdometerKm
        : widget.records.last.odometerKm;
    _form = RefuelFormController(initialOdometerKm: latest)
      ..addListener(_handleFormChanged);
  }

  @override
  void dispose() {
    _form
      ..removeListener(_handleFormChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFormChanged() {
    if (mounted) {
      setState(() {});
    }
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
              controller: _form.odometerController,
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
                    child: RefuelCompactInput(
                      controller: _form.unitPriceController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelCompactInput(
                      controller: _form.litersController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelCompactInput(
                      controller: _form.machineAmountController,
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
                        controller: _form.paidUnitPriceController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelFieldColumn(
                      label: '优惠金额',
                      child: RefuelCompactInput(
                        controller: _form.discountController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RefuelFieldColumn(
                      label: '实付金额',
                      child: RefuelCompactInput(
                        controller: _form.paidAmountController,
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
      _form.buildDraft(
        id: const Uuid().v4(),
        vehicleId: widget.vehicle.id,
        date: _date,
        isFull: _isFull,
        warningLightOn: _warningLightOn,
        fuelGrade: _fuelGrade,
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
