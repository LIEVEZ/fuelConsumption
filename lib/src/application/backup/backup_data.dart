import 'package:fuel_consumption/src/domain/models.dart';

class BackupData {
  const BackupData({
    required this.schemaVersion,
    required this.exportedAt,
    required this.vehicles,
    required this.records,
    this.maintenanceRecords = const [],
  });

  final int schemaVersion;
  final DateTime exportedAt;
  final List<Vehicle> vehicles;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;
}
