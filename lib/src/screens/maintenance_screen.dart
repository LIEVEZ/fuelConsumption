import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/record_form_support.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({
    required this.vehicle,
    required this.onSave,
    required this.onSaved,
    super.key,
  });

  final Vehicle vehicle;
  final Future<MaintenanceRecord> Function(MaintenanceRecordInput input) onSave;
  final VoidCallback onSaved;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with RecordFormSubmitState<MaintenanceScreen> {
  final _costController = TextEditingController();
  final _shopController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  MaintenanceCategory _category = MaintenanceCategory.regular;

  @override
  void dispose() {
    _costController.dispose();
    _shopController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      children: [
        SectionHeader(title: '保养记录', subtitle: widget.vehicle.name),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _ValueTile(
                label: '保养日期',
                value: shortDate(_date),
                onTap: _pickDate,
              ),
              const Divider(height: 1),
              _ValueTile(
                label: '保养类别',
                value: _category.label,
                onTap: _pickCategory,
              ),
              const Divider(height: 1),
              _InputTile(
                label: '保养费用',
                controller: _costController,
                suffix: '元',
              ),
              const Divider(height: 1),
              _InputTile(label: '保养门店', controller: _shopController),
              const Divider(height: 1),
              _InputTile(label: '备注', controller: _noteController),
            ],
          ),
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
    final picked = await pickRecordDate(
      context: context,
      current: _date,
      keepTime: false,
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  Future<void> _pickCategory() async {
    final selected = await showModalBottomSheet<MaintenanceCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            for (final category in MaintenanceCategory.values)
              ListTile(
                leading: Icon(maintenanceIcon(category)),
                title: Text(category.label),
                trailing: category == _category
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(category),
              ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _category = selected);
  }

  Future<void> _save() async {
    return submitRecord(
      save: () async {
        await widget.onSave(
          MaintenanceRecordInput(
            vehicleId: widget.vehicle.id,
            date: _date,
            category: _category,
            costText: _costController.text,
            shopText: _shopController.text,
            noteText: _noteController.text,
          ),
        );
      },
      successMessage: '已保存保养记录',
      onSaved: widget.onSaved,
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(value), const Icon(Icons.chevron_right)],
      ),
      onTap: onTap,
    );
  }
}

class _InputTile extends StatelessWidget {
  const _InputTile({
    required this.label,
    required this.controller,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 88, child: Text(label)),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              keyboardType: suffix == null
                  ? TextInputType.text
                  : const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(suffixText: suffix),
            ),
          ),
        ],
      ),
    );
  }
}
