import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/statistics.dart';

typedef DashboardDataWidgetBuilder =
    Widget Function(BuildContext context, DashboardData data);
typedef DashboardEmptyWidgetBuilder =
    Widget Function(BuildContext context, List<Vehicle> vehicles);
typedef DashboardLoadingWidgetBuilder =
    Widget Function(
      BuildContext context,
      List<Vehicle> vehicles,
      Vehicle? selectedVehicle,
    );
typedef DashboardErrorWidgetBuilder =
    Widget Function(
      BuildContext context,
      List<Vehicle> vehicles,
      Vehicle? selectedVehicle,
      Object error,
    );

class DashboardDataBuilder extends StatelessWidget {
  const DashboardDataBuilder({
    required this.repository,
    required this.selectedVehicleId,
    required this.builder,
    required this.emptyBuilder,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });

  final AppRepository repository;
  final String? selectedVehicleId;
  final DashboardDataWidgetBuilder builder;
  final DashboardEmptyWidgetBuilder emptyBuilder;
  final DashboardLoadingWidgetBuilder loadingBuilder;
  final DashboardErrorWidgetBuilder errorBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Vehicle>>(
      stream: repository.watchVehicles(),
      builder: (context, vehicleSnapshot) {
        if (vehicleSnapshot.hasError) {
          return errorBuilder(
            context,
            const <Vehicle>[],
            null,
            vehicleSnapshot.error!,
          );
        }
        if (!vehicleSnapshot.hasData) {
          return loadingBuilder(context, const <Vehicle>[], null);
        }

        final vehicles = vehicleSnapshot.data ?? const <Vehicle>[];
        final selectedVehicle = resolveDashboardVehicle(
          vehicles,
          selectedVehicleId,
        );
        if (selectedVehicle == null) {
          return emptyBuilder(context, vehicles);
        }

        return StreamBuilder<List<EnergyRecord>>(
          stream: repository.watchRecords(selectedVehicle.id),
          builder: (context, recordSnapshot) {
            if (recordSnapshot.hasError) {
              return errorBuilder(
                context,
                vehicles,
                selectedVehicle,
                recordSnapshot.error!,
              );
            }
            if (!recordSnapshot.hasData) {
              return loadingBuilder(context, vehicles, selectedVehicle);
            }

            final records = recordSnapshot.data ?? const <EnergyRecord>[];
            final chronological = [...records]
              ..sort((a, b) => a.date.compareTo(b.date));
            final stats = EnergyStatisticsCalculator().build(
              selectedVehicle,
              chronological,
            );

            return StreamBuilder<List<MaintenanceRecord>>(
              stream: repository.watchMaintenanceRecords(selectedVehicle.id),
              builder: (context, maintenanceSnapshot) {
                if (maintenanceSnapshot.hasError) {
                  return errorBuilder(
                    context,
                    vehicles,
                    selectedVehicle,
                    maintenanceSnapshot.error!,
                  );
                }
                if (!maintenanceSnapshot.hasData) {
                  return loadingBuilder(context, vehicles, selectedVehicle);
                }

                return builder(
                  context,
                  DashboardData(
                    vehicles: vehicles,
                    selectedVehicle: selectedVehicle,
                    records: records,
                    chronologicalRecords: chronological,
                    maintenanceRecords:
                        maintenanceSnapshot.data ?? const <MaintenanceRecord>[],
                    stats: stats,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
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

  final List<Vehicle> vehicles;
  final Vehicle selectedVehicle;
  final List<EnergyRecord> records;
  final List<EnergyRecord> chronologicalRecords;
  final List<MaintenanceRecord> maintenanceRecords;
  final StatisticsSnapshot stats;
}

class DashboardLoadingState extends StatelessWidget {
  const DashboardLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class DashboardErrorState extends StatelessWidget {
  const DashboardErrorState({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('数据加载失败', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
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
