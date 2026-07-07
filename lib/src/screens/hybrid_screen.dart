import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/refuel/refuel_form_widgets.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class HybridScreen extends StatefulWidget {
  const HybridScreen({
    required this.vehicle,
    required this.records,
    required this.onSave,
    required this.onSaved,
    super.key,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final Future<EnergyRecord> Function(HybridRecordInput input) onSave;
  final VoidCallback onSaved;

  @override
  State<HybridScreen> createState() => _HybridScreenState();
}

class _HybridScreenState extends State<HybridScreen> {
  final _odometerController = TextEditingController();
  final _litersController = TextEditingController(text: '0.00');
  final _fuelUnitPriceController = TextEditingController(text: '0.00');
  final _kwhController = TextEditingController(text: '0.00');
  final _electricityUnitPriceController = TextEditingController(text: '0.00');
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

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
    _litersController.dispose();
    _fuelUnitPriceController.dispose();
    _kwhController.dispose();
    _electricityUnitPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      children: [
        SectionHeader(title: '油电补能', subtitle: widget.vehicle.name),
        const SizedBox(height: 12),
        RefuelFormSection(
          children: [
            RefuelValueRow(
              label: '补能日期',
              required: true,
              value: shortDate(_date),
              onTap: _pickDate,
            ),
            RefuelValueRow(
              label: '补能时间',
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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                '燃油',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            RefuelInputRow(
              label: '加油量',
              controller: _litersController,
              suffix: '升',
            ),
            RefuelInputRow(
              label: '燃油单价',
              controller: _fuelUnitPriceController,
              suffix: '元/升',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                '电量',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            RefuelInputRow(
              label: '充电电量',
              controller: _kwhController,
              suffix: 'kWh',
            ),
            RefuelInputRow(
              label: '充电单价',
              controller: _electricityUnitPriceController,
              suffix: '元/kWh',
            ),
            RefuelInputRow(
              label: '备注',
              controller: _noteController,
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
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

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        HybridRecordInput(
          vehicleId: widget.vehicle.id,
          date: _date,
          odometerText: _odometerController.text,
          litersText: _litersController.text,
          fuelUnitPriceText: _fuelUnitPriceController.text,
          kwhText: _kwhController.text,
          electricityUnitPriceText: _electricityUnitPriceController.text,
          noteText: _noteController.text,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存油电补能记录')));
      widget.onSaved();
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
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
