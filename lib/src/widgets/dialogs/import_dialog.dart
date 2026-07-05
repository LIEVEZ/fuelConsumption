import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({required this.repository, super.key});

  final AppRepository repository;

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('导入 JSON'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 360),
        child: SingleChildScrollView(
          child: TextField(
            controller: _controller,
            minLines: 8,
            maxLines: 12,
            decoration: InputDecoration(
              labelText: '粘贴 JSON 备份',
              errorText: _error,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _import, child: const Text('导入')),
      ],
    );
  }

  Future<void> _import() async {
    try {
      final backup = BackupCodec().decode(_controller.text);
      await widget.repository.importBackup(backup);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      setState(() => _error = error.toString());
    }
  }
}
