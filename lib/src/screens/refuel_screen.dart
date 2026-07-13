import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/fuel_grades.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/record_form_support.dart';
import 'package:fuel_consumption/src/screens/refuel_form_controller.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/refuel/refuel_form_widgets.dart';

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
  final Future<EnergyRecord> Function(RefuelRecordInput input) onSave;
  final VoidCallback onSaved;

  @override
  State<RefuelScreen> createState() => _RefuelScreenState();
}

class _RefuelScreenState extends State<RefuelScreen>
    with RecordFormSubmitState<RefuelScreen> {
  late final RefuelFormController _form;
  DateTime _date = DateTime.now();
  bool _isFull = true;
  bool _warningLightOn = false;
  String _fuelGrade = defaultFuelGrade;

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
          child: RecordSaveButton(
            saving: saving,
            onPressed: _save,
            height: 58,
            fontSize: 20,
          ),
        ),
        if (errorText != null)
          RecordFormErrorText(
            error: errorText!,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
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
    final picked = await pickRecordDate(context: context, current: _date);
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await pickRecordTime(context: context, current: _date);
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
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
    return submitRecord(
      save: () async {
        await widget.onSave(
          RefuelRecordInput(
            vehicleId: widget.vehicle.id,
            date: _date,
            odometerText: _form.odometerController.text,
            unitPriceText: _form.unitPriceController.text,
            litersText: _form.litersController.text,
            machineAmountText: _form.machineAmountController.text,
            paidUnitPriceText: _form.paidUnitPriceController.text,
            discountText: _form.discountController.text,
            paidAmountText: _form.paidAmountController.text,
            isFull: _isFull,
            warningLightOn: _warningLightOn,
            fuelGrade: _fuelGrade,
            noteText: _form.noteController.text,
          ),
        );
      },
      successMessage: '已保存加油记录',
      onSaved: widget.onSaved,
    );
  }
}
