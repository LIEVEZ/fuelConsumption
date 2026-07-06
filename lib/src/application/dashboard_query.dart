import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/data/repository_provider.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/statistics.dart';

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(repositoryProvider).watchVehicles();
});

final vehicleRecordsProvider =
    StreamProvider.family<List<EnergyRecord>, String>((ref, vehicleId) {
      return ref.watch(repositoryProvider).watchRecords(vehicleId);
    });

final vehicleMaintenanceRecordsProvider =
    StreamProvider.family<List<MaintenanceRecord>, String>((ref, vehicleId) {
      return ref.watch(repositoryProvider).watchMaintenanceRecords(vehicleId);
    });

final dashboardQueryProvider = Provider.family<DashboardLoadState, String?>((
  ref,
  selectedVehicleId,
) {
  final vehiclesValue = ref.watch(vehiclesProvider);
  final vehicles = vehiclesValue.currentValue ?? const <Vehicle>[];
  final selectedVehicle = resolveDashboardVehicle(vehicles, selectedVehicleId);

  if (vehiclesValue.hasError) {
    return DashboardLoadState.error(
      error: vehiclesValue.error!,
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
    );
  }
  if (vehiclesValue.isLoading && !vehiclesValue.hasValue) {
    return DashboardLoadState.loading(
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
    );
  }
  if (selectedVehicle == null) {
    return DashboardLoadState.empty(vehicles: vehicles);
  }

  final recordsValue = ref.watch(vehicleRecordsProvider(selectedVehicle.id));
  final records = recordsValue.currentValue ?? const <EnergyRecord>[];
  if (recordsValue.hasError) {
    return DashboardLoadState.error(
      error: recordsValue.error!,
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
    );
  }
  if (recordsValue.isLoading && !recordsValue.hasValue) {
    return DashboardLoadState.loading(
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
    );
  }

  final maintenanceValue = ref.watch(
    vehicleMaintenanceRecordsProvider(selectedVehicle.id),
  );
  if (maintenanceValue.hasError) {
    return DashboardLoadState.error(
      error: maintenanceValue.error!,
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
    );
  }
  if (maintenanceValue.isLoading && !maintenanceValue.hasValue) {
    return DashboardLoadState.loading(
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
    );
  }

  return DashboardLoadState.ready(
    DashboardData.fromRecords(
      vehicles: vehicles,
      selectedVehicle: selectedVehicle,
      records: records,
      maintenanceRecords:
          maintenanceValue.currentValue ?? const <MaintenanceRecord>[],
    ),
  );
});

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

extension _AsyncValueCurrentValue<T> on AsyncValue<T> {
  T? get currentValue => hasValue ? value : null;
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
