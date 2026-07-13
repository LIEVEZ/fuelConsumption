import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/record_form_support.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/refuel/refuel_form_widgets.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class ChargeScreen extends StatefulWidget {
  const ChargeScreen({
    required this.vehicle,
    required this.records,
    required this.onSave,
    required this.onSaved,
    super.key,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final Future<EnergyRecord> Function(ChargeRecordInput input) onSave;
  final VoidCallback onSaved;

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen>
    with RecordFormSubmitState<ChargeScreen> {
  final _odometerController = TextEditingController();
  final _kwhController = TextEditingController(text: '0.00');
  final _unitPriceController = TextEditingController(text: '0.00');
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  ChargeMode _chargeMode = ChargeMode.slow;

  @override
  void initState() {
    super.initState();
    final latest = widget.records.isEmpty
        ? widget.vehicle.initialOdometerKm
        : widget.records.last.odometerKm;
    _odometerController.text = latest.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _kwhController.dispose();
    _unitPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      children: [
        SectionHeader(title: '充电记录', subtitle: widget.vehicle.name),
        const SizedBox(height: 12),
        RefuelFormSection(
          children: [
            RefuelValueRow(
              label: '充电日期',
              required: true,
              value: shortDate(_date),
              onTap: _pickDate,
            ),
            RefuelValueRow(
              label: '充电时间',
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
            RefuelInputRow(
              label: '充电电量',
              required: true,
              controller: _kwhController,
              suffix: 'kWh',
            ),
            RefuelInputRow(
              label: '充电单价',
              required: true,
              controller: _unitPriceController,
              suffix: '元/kWh',
            ),
            RefuelSegmentRow(
              label: '充电方式',
              leftLabel: ChargeMode.slow.label,
              rightLabel: ChargeMode.fast.label,
              selectedRight: _chargeMode == ChargeMode.fast,
              onChanged: (right) => setState(
                () => _chargeMode = right ? ChargeMode.fast : ChargeMode.slow,
              ),
            ),
            RefuelInputRow(
              label: '备注',
              controller: _noteController,
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          RecordFormErrorText(error: errorText!),
        ],
        const SizedBox(height: 24),
        RecordSaveButton(saving: saving, onPressed: _save),
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

  Future<void> _save() async {
    return submitRecord(
      save: () async {
        await widget.onSave(
          ChargeRecordInput(
            vehicleId: widget.vehicle.id,
            date: _date,
            odometerText: _odometerController.text,
            kwhText: _kwhController.text,
            unitPriceText: _unitPriceController.text,
            chargeMode: _chargeMode,
            noteText: _noteController.text,
          ),
        );
      },
      successMessage: '已保存充电记录',
      onSaved: widget.onSaved,
    );
  }
}
