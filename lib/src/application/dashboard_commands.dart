import 'package:fuel_consumption/src/application/backup/backup_codec.dart';
import 'package:fuel_consumption/src/application/backup_import_service.dart';
import 'package:fuel_consumption/src/application/ports/app_repository.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/application/vehicle_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:uuid/uuid.dart';

class DashboardCommandService {
  DashboardCommandService({
    required AppRepository repository,
    BackupCodec? backupCodec,
    Uuid? uuid,
  }) : _repository = repository,
       _backupCodec = backupCodec ?? BackupCodec(),
       _recordCommands = RecordCommandService(
         repository: repository,
         generateId: uuid?.v4,
       ),
       _vehicleCommands = VehicleCommandService(
         repository: repository,
         uuid: uuid,
       );

  final AppRepository _repository;
  final BackupCodec _backupCodec;
  final RecordCommandService _recordCommands;
  final VehicleCommandService _vehicleCommands;

  ImportDialogActions get importActions {
    return BackupImportService(repository: _repository, codec: _backupCodec);
  }

  Future<void> createVehicle(VehicleDraft draft) {
    return _vehicleCommands.createVehicle(draft);
  }

  Future<void> deleteVehicle(String vehicleId) {
    return _repository.deleteVehicle(vehicleId);
  }

  Future<EnergyRecord> saveRefuelRecord(RefuelRecordInput input) {
    return _recordCommands.saveRefuel(input);
  }

  Future<EnergyRecord> saveChargeRecord(ChargeRecordInput input) {
    return _recordCommands.saveCharge(input);
  }

  Future<EnergyRecord> saveHybridRecord(HybridRecordInput input) {
    return _recordCommands.saveHybrid(input);
  }

  Future<MaintenanceRecord> saveMaintenanceRecord(
    MaintenanceRecordInput input,
  ) {
    return _recordCommands.saveMaintenance(input);
  }

  Future<String> exportBackupJson() async {
    final backup = await _repository.exportBackup();
    return _backupCodec.encode(backup);
  }
}
