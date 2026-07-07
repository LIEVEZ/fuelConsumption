import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/backup/backup_data.dart';
import 'package:fuel_consumption/src/application/dashboard_query.dart';
import 'package:fuel_consumption/src/application/ports/app_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/presentation/app_providers.dart';

void main() {
  test('query provider emits ready data from repository streams', () async {
    final repository = _FakeDashboardRepository(
      vehicles: [_vehicle()],
      records: [
        _fuelRecord(id: 'record-1', date: DateTime(2026, 7), odometerKm: 100),
      ],
      maintenanceRecords: [
        MaintenanceRecord(
          id: 'maintenance-1',
          vehicleId: 'vehicle-1',
          date: DateTime(2026, 7, 3),
          category: MaintenanceCategory.regular,
          cost: 300,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [appRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final state = await _readDashboardState(container, null);

    expect(state.status, DashboardLoadStatus.ready);
    expect(state.data?.selectedVehicle.id, 'vehicle-1');
    expect(state.data?.records, hasLength(1));
    expect(state.data?.maintenanceRecords, hasLength(1));
  });

  test('query provider reports empty when there are no vehicles', () async {
    final container = ProviderContainer(
      overrides: [
        appRepositoryProvider.overrideWithValue(
          _FakeDashboardRepository(vehicles: const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await _readDashboardState(container, null);

    expect(state.status, DashboardLoadStatus.empty);
    expect(state.vehicles, isEmpty);
  });

  test(
    'query provider keeps selected vehicle context on record errors',
    () async {
      final container = ProviderContainer(
        overrides: [
          appRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(
              vehicles: [_vehicle()],
              recordError: StateError('records failed'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await _readDashboardState(container, null);

      expect(state.status, DashboardLoadStatus.error);
      expect(state.selectedVehicle?.id, 'vehicle-1');
      expect(state.error.toString(), contains('records failed'));
    },
  );
}

Future<DashboardLoadState> _readDashboardState(
  ProviderContainer container,
  String? selectedVehicleId,
) async {
  final provider = dashboardQueryProvider(selectedVehicleId);
  final subscription = container.listen(
    provider,
    (_, _) {},
    fireImmediately: true,
  );
  try {
    for (var index = 0; index < 12; index++) {
      await Future<void>.delayed(Duration.zero);
      await container.pump();
      final state = subscription.read();
      if (state.status != DashboardLoadStatus.loading) {
        return state;
      }
    }
    return subscription.read();
  } finally {
    subscription.close();
  }
}

Vehicle _vehicle() {
  return const Vehicle(
    id: 'vehicle-1',
    name: '测试车',
    type: VehicleType.fuel,
    initialOdometerKm: 0,
  );
}

EnergyRecord _fuelRecord({
  required String id,
  required DateTime date,
  required double odometerKm,
}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: 'vehicle-1',
    date: date,
    odometerKm: odometerKm,
    liters: 10,
    unitPrice: 7,
    isFull: true,
  );
}

class _FakeDashboardRepository implements AppRepository {
  const _FakeDashboardRepository({
    required this.vehicles,
    this.records = const [],
    this.maintenanceRecords = const [],
    this.recordError,
  });

  final List<Vehicle> vehicles;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;
  final Object? recordError;

  @override
  Stream<List<Vehicle>> watchVehicles() {
    return Stream.value(vehicles);
  }

  @override
  Stream<List<EnergyRecord>> watchRecords(String vehicleId) {
    if (recordError != null) {
      return Stream.error(recordError!);
    }
    return Stream.value(records);
  }

  @override
  Stream<List<MaintenanceRecord>> watchMaintenanceRecords(String vehicleId) {
    return Stream.value(maintenanceRecords);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {}

  @override
  Future<BackupData> exportBackup() async {
    return BackupData(
      schemaVersion: 1,
      exportedAt: DateTime(2026),
      vehicles: vehicles,
      records: records,
      maintenanceRecords: maintenanceRecords,
    );
  }

  @override
  Future<List<MaintenanceRecord>> getMaintenanceRecords([
    String? vehicleId,
  ]) async {
    return maintenanceRecords;
  }

  @override
  Future<List<EnergyRecord>> getRecords([String? vehicleId]) async {
    return records;
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    return vehicles;
  }

  @override
  Future<void> importBackup(BackupData data) async {}

  @override
  Future<void> saveMaintenanceRecord(MaintenanceRecord record) async {}

  @override
  Future<void> saveRecord(EnergyRecord record) async {}

  @override
  Future<void> saveVehicle(Vehicle vehicle) async {}

  @override
  Future<void> validateBackup(BackupData data) async {}
}
