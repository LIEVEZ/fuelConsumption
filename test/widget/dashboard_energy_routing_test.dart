import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/backup/backup_data.dart';
import 'package:fuel_consumption/src/application/ports/app_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/presentation/app_providers.dart';
import 'package:fuel_consumption/src/screens/dashboard_screen.dart';

void main() {
  testWidgets('routes motorcycles from bottom energy tab to refuel form', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      Vehicle(
        id: 'vehicle-motorcycle',
        name: '摩托车',
        type: VehicleType.motorcycle,
        initialOdometerKm: 1000,
      ),
    );

    await tester.tap(find.text('补能'));
    await tester.pumpAndSettle();

    expect(find.text('优惠加油'), findsOneWidget);
    expect(find.text('加油日期'), findsOneWidget);
  });

  testWidgets(
    'routes electric vehicles from bottom energy tab to charge form',
    (tester) async {
      await _pumpDashboard(
        tester,
        Vehicle(
          id: 'vehicle-electric',
          name: '电车',
          type: VehicleType.electric,
          initialOdometerKm: 1000,
        ),
      );

      await tester.tap(find.text('补能'));
      await tester.pumpAndSettle();

      expect(find.text('充电记录'), findsOneWidget);
      expect(find.text('充电电量'), findsOneWidget);
    },
  );

  testWidgets('routes hybrid vehicles from bottom energy tab to hybrid form', (
    tester,
  ) async {
    await _pumpDashboard(
      tester,
      Vehicle(
        id: 'vehicle-hybrid',
        name: '插混',
        type: VehicleType.hybrid,
        initialOdometerKm: 1000,
      ),
    );

    await tester.tap(find.text('补能'));
    await tester.pumpAndSettle();

    expect(find.text('油电补能'), findsWidgets);
    expect(find.text('加油量'), findsOneWidget);
    expect(find.text('充电电量'), findsOneWidget);
  });
}

Future<void> _pumpDashboard(WidgetTester tester, Vehicle vehicle) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appRepositoryProvider.overrideWithValue(
          _FakeRepository(vehicle: vehicle),
        ),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeRepository implements AppRepository {
  const _FakeRepository({required this.vehicle});

  final Vehicle vehicle;

  @override
  Stream<List<Vehicle>> watchVehicles() {
    return Stream.value([vehicle]);
  }

  @override
  Stream<List<EnergyRecord>> watchRecords(String vehicleId) {
    return Stream.value(const []);
  }

  @override
  Stream<List<MaintenanceRecord>> watchMaintenanceRecords(String vehicleId) {
    return Stream.value(const []);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {}

  @override
  Future<BackupData> exportBackup() async {
    return BackupData(
      schemaVersion: 1,
      exportedAt: DateTime(2026),
      vehicles: [vehicle],
      records: const [],
    );
  }

  @override
  Future<List<MaintenanceRecord>> getMaintenanceRecords([
    String? vehicleId,
  ]) async {
    return const [];
  }

  @override
  Future<List<EnergyRecord>> getRecords([String? vehicleId]) async {
    return const [];
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    return [vehicle];
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
