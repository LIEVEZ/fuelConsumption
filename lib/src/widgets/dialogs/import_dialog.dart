import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/domain/models.dart';

class ImportBackupResult {
  const ImportBackupResult({required this.preImportBackupJson});

  final String preImportBackupJson;
}

class ImportDialog extends StatefulWidget {
  const ImportDialog({required this.repository, super.key});

  final AppRepository repository;

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _controller = TextEditingController();
  BackupData? _preview;
  bool _importing = false;
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
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                minLines: 8,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: '粘贴 JSON 备份',
                  errorText: _error,
                ),
                onChanged: (_) => setState(() {
                  _preview = null;
                  _error = null;
                }),
              ),
              if (_preview != null) ...[
                const SizedBox(height: 14),
                _ImportPreviewCard(data: _preview!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _importing ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        if (_preview == null)
          FilledButton(
            onPressed: _importing ? null : _parse,
            child: _importing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Text('解析预览'),
          )
        else
          FilledButton(
            onPressed: _importing ? null : _confirmImport,
            child: _importing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Text('确认替换导入'),
          ),
      ],
    );
  }

  Future<void> _parse() async {
    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final backup = BackupCodec().decode(_controller.text);
      await widget.repository.validateBackup(backup);
      if (!mounted) return;
      setState(() {
        _preview = backup;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  Future<void> _confirmImport() async {
    final backup = _preview;
    if (backup == null) {
      await _parse();
      return;
    }

    setState(() {
      _importing = true;
      _error = null;
    });
    try {
      final preImportBackup = await widget.repository.exportBackup();
      final preImportBackupJson = BackupCodec().encode(preImportBackup);
      await widget.repository.importBackup(backup);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(ImportBackupResult(preImportBackupJson: preImportBackupJson));
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }
}

class _ImportPreviewCard extends StatelessWidget {
  const _ImportPreviewCard({required this.data});

  final BackupData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '导入预览',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text('车辆：${data.vehicles.length} 辆'),
          Text('加油/补能记录：${data.records.length} 条'),
          Text('保养记录：${data.maintenanceRecords.length} 条'),
          const SizedBox(height: 8),
          Text(
            '确认后会替换当前本地数据。系统会先自动导出现有数据，导入成功后展示备份 JSON。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
