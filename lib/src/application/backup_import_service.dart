import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/domain/models.dart';

abstract class ImportDialogActions {
  Future<BackupData> parseAndValidate(String source);

  Future<ImportBackupResult> importBackup(BackupData data);
}

class ImportBackupResult {
  const ImportBackupResult({required this.preImportBackupJson});

  final String preImportBackupJson;
}

class BackupImportService implements ImportDialogActions {
  BackupImportService({required AppRepository repository, BackupCodec? codec})
    : _repository = repository,
      _codec = codec ?? BackupCodec();

  final AppRepository _repository;
  final BackupCodec _codec;

  @override
  Future<BackupData> parseAndValidate(String source) async {
    final backup = _codec.decode(source);
    await _repository.validateBackup(backup);
    return backup;
  }

  @override
  Future<ImportBackupResult> importBackup(BackupData data) async {
    final preImportBackup = await _repository.exportBackup();
    final preImportBackupJson = _codec.encode(preImportBackup);
    await _repository.importBackup(data);
    return ImportBackupResult(preImportBackupJson: preImportBackupJson);
  }
}
