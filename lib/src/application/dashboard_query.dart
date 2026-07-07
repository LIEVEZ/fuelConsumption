import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/statistics.dart';

enum DashboardLoadStatus { loading, empty, ready, error }

class DashboardLoadState {
  const DashboardLoadState._({
    required this.status,
    required this.vehicles,
    this.selectedVehicle,
    this.data,
    this.error,
  });

  const DashboardLoadState.loading({
    required List<Vehicle> vehicles,
    Vehicle? selectedVehicle,
  }) : this._(
         status: DashboardLoadStatus.loading,
         vehicles: vehicles,
         selectedVehicle: selectedVehicle,
       );

  const DashboardLoadState.empty({required List<Vehicle> vehicles})
    : this._(status: DashboardLoadStatus.empty, vehicles: vehicles);

  factory DashboardLoadState.ready(DashboardData data) {
    return DashboardLoadState._(
      status: DashboardLoadStatus.ready,
      vehicles: data.vehicles,
      selectedVehicle: data.selectedVehicle,
      data: data,
    );
  }

  const DashboardLoadState.error({
    required Object error,
    required List<Vehicle> vehicles,
    Vehicle? selectedVehicle,
  }) : this._(
         status: DashboardLoadStatus.error,
         vehicles: vehicles,
         selectedVehicle: selectedVehicle,
         error: error,
       );

  final DashboardLoadStatus status;
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final DashboardData? data;
  final Object? error;
}

class DashboardData {
  const DashboardData({
    required this.vehicles,
    required this.selectedVehicle,
    required this.records,
    required this.chronologicalRecords,
    required this.maintenanceRecords,
    required this.stats,
  });

  factory DashboardData.fromRecords({
    required List<Vehicle> vehicles,
    required Vehicle selectedVehicle,
    required List<EnergyRecord> records,
    required List<MaintenanceRecord> maintenanceRecords,
  }) {
    final chronological = [...records]
      ..sort((a, b) => a.date.compareTo(b.date));
    return DashboardData(
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
      records: records,
      chronologicalRecords: chronological,
      maintenanceRecords: maintenanceRecords,
      stats: EnergyStatisticsCalculator().build(selectedVehicle, chronological),
    );
  }

  final List<Vehicle> vehicles;
  final Vehicle selectedVehicle;
  final List<EnergyRecord> records;
  final List<EnergyRecord> chronologicalRecords;
  final List<MaintenanceRecord> maintenanceRecords;
  final StatisticsSnapshot stats;
}

Vehicle? resolveDashboardVehicle(
  List<Vehicle> vehicles,
  String? selectedVehicleId,
) {
  if (vehicles.isEmpty) return null;
  return vehicles.firstWhere(
    (vehicle) => vehicle.id == selectedVehicleId,
    orElse: () => vehicles.firstWhere(
      (vehicle) => vehicle.isDefault,
      orElse: () => vehicles.first,
    ),
  );
}
