import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/application/vehicle_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';

class VehicleDialog extends StatefulWidget {
  const VehicleDialog({required this.onSave, super.key});

  final Future<void> Function(VehicleDraft draft) onSave;

  @override
  State<VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<VehicleDialog> {
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _odometerController = TextEditingController(text: '0');
  VehicleType _type = VehicleType.fuel;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('添加车辆', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '车辆名称',
                        errorText: _error,
                      ),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: '车型/备注'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _odometerController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: '初始里程 km'),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final type in VehicleType.values)
                            ChoiceChip(
                              label: Text(
                                type == VehicleType.fuel ? '油车' : type.label,
                              ),
                              selected: _type == type,
                              onSelected: (_) => setState(() => _type = type),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                              ),
                            )
                          : const Text('保存车辆'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请填写车辆名称');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        VehicleDraft(
          name: name,
          type: _type,
          initialOdometerKm: double.tryParse(_odometerController.text) ?? 0,
          model: _modelController.text.trim(),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
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
