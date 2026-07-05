import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';
import 'package:uuid/uuid.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({
    required this.vehicle,
    required this.onSave,
    required this.onSaved,
    super.key,
  });

  final Vehicle vehicle;
  final Future<void> Function(MaintenanceRecord record) onSave;
  final VoidCallback onSaved;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _costController = TextEditingController();
  final _shopController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  MaintenanceCategory _category = MaintenanceCategory.regular;
  bool _saving = false;
  String? _error;

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
                leading: Icon(_categoryIcon(category)),
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
    final cost = double.tryParse(_costController.text);
    if (cost == null || cost <= 0) {
      setState(() => _error = '请填写有效保养费用');
      return;
    }

    final record = MaintenanceRecord(
      id: const Uuid().v4(),
      vehicleId: widget.vehicle.id,
      date: _date,
      category: _category,
      cost: cost,
      shop: _shopController.text.trim(),
      note: _noteController.text.trim(),
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(record);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已保存保养记录')));
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

IconData _categoryIcon(MaintenanceCategory category) {
  return switch (category) {
    MaintenanceCategory.regular => Icons.build_circle_outlined,
    MaintenanceCategory.oil => Icons.oil_barrel_outlined,
    MaintenanceCategory.tire => Icons.album_outlined,
    MaintenanceCategory.repair => Icons.handyman_outlined,
    MaintenanceCategory.wash => Icons.local_car_wash_outlined,
    MaintenanceCategory.insurance => Icons.verified_user_outlined,
    MaintenanceCategory.other => Icons.more_horiz,
  };
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
