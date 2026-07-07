import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/application/dashboard_commands.dart';
import 'package:fuel_consumption/src/application/dashboard_query.dart';
import 'package:fuel_consumption/src/application/ports/app_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) {
  throw UnimplementedError('AppRepository implementation was not provided.');
});

final dashboardCommandProvider = Provider<DashboardCommandService>((ref) {
  return DashboardCommandService(repository: ref.watch(appRepositoryProvider));
});

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(appRepositoryProvider).watchVehicles();
});

final vehicleRecordsProvider =
    StreamProvider.family<List<EnergyRecord>, String>((ref, vehicleId) {
      return ref.watch(appRepositoryProvider).watchRecords(vehicleId);
    });

final vehicleMaintenanceRecordsProvider =
    StreamProvider.family<List<MaintenanceRecord>, String>((ref, vehicleId) {
      return ref
          .watch(appRepositoryProvider)
          .watchMaintenanceRecords(vehicleId);
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

extension _AsyncValueCurrentValue<T> on AsyncValue<T> {
  T? get currentValue => hasValue ? value : null;
}
