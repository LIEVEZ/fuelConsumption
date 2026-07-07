import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/backup/backup_data.dart';
import 'package:fuel_consumption/src/data/app_database.dart';
import 'package:fuel_consumption/src/data/fuel_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  late AppDatabase database;
  late FuelRepository repository;

  setUp(() {
    database = AppDatabase.inMemory();
    repository = FuelRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saveRecord validates through repository', () async {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
      isDefault: true,
    );
    await repository.saveVehicle(vehicle);

    final record = EnergyRecord.fuel(
      id: 'record-1',
      vehicleId: vehicle.id,
      date: DateTime(2026),
      odometerKm: 100,
      liters: 0,
      unitPrice: 7.25,
      isFull: true,
    );

    await expectLater(
      repository.saveRecord(record),
      throwsA(isA<FormatException>()),
    );
  });

  test('saveMaintenanceRecord validates through repository', () async {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
      isDefault: true,
    );
    await repository.saveVehicle(vehicle);

    final record = MaintenanceRecord(
      id: 'maintenance-1',
      vehicleId: vehicle.id,
      date: DateTime(2026),
      category: MaintenanceCategory.regular,
      cost: 0,
    );

    await expectLater(
      repository.saveMaintenanceRecord(record),
      throwsA(isA<FormatException>()),
    );
  });

  test('persists structured refuel amount fields', () async {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
      isDefault: true,
    );
    await repository.saveVehicle(vehicle);

    await repository.saveRecord(
      EnergyRecord.fuel(
        id: 'record-1',
        vehicleId: vehicle.id,
        date: DateTime(2026),
        odometerKm: 100,
        liters: 20,
        unitPrice: 7,
        isFull: true,
        machineAmount: 160,
        paidAmount: 140,
        discountAmount: 20,
      ),
    );

    final record = (await repository.getRecords(vehicle.id)).single;

    expect(record.machineAmount, 160);
    expect(record.paidAmount, 140);
    expect(record.discountAmount, 20);
    expect(record.totalCost, 140);
  });

  test('persists charge and hybrid records through repository', () async {
    final electricVehicle = Vehicle(
      id: 'vehicle-electric',
      name: '电车',
      type: VehicleType.electric,
      initialOdometerKm: 1000,
    );
    final hybridVehicle = Vehicle(
      id: 'vehicle-hybrid',
      name: '插混',
      type: VehicleType.hybrid,
      initialOdometerKm: 1000,
    );
    await repository.saveVehicle(electricVehicle);
    await repository.saveVehicle(hybridVehicle);

    await repository.saveRecord(
      EnergyRecord.charge(
        id: 'charge-1',
        vehicleId: electricVehicle.id,
        date: DateTime(2026),
        odometerKm: 1100,
        kwh: 40,
        unitPrice: 0.6,
        chargeMode: ChargeMode.fast,
      ),
    );
    await repository.saveRecord(
      EnergyRecord.hybrid(
        id: 'hybrid-1',
        vehicleId: hybridVehicle.id,
        date: DateTime(2026),
        odometerKm: 1200,
        liters: 18,
        fuelUnitPrice: 7.5,
        kwh: 12,
        electricityUnitPrice: 0.6,
      ),
    );

    final charge = (await repository.getRecords(electricVehicle.id)).single;
    final hybrid = (await repository.getRecords(hybridVehicle.id)).single;

    expect(charge.energyType, EnergyType.charge);
    expect(charge.kwh, 40);
    expect(charge.electricityUnitPrice, 0.6);
    expect(charge.chargeMode, ChargeMode.fast);
    expect(charge.totalCost, 24);
    expect(charge.fuelLiters, isNull);

    expect(hybrid.energyType, EnergyType.hybrid);
    expect(hybrid.fuelLiters, 18);
    expect(hybrid.fuelUnitPrice, 7.5);
    expect(hybrid.kwh, 12);
    expect(hybrid.electricityUnitPrice, 0.6);
    expect(hybrid.totalCost, closeTo(142.2, 0.001));
  });

  test('exports and imports mixed energy records', () async {
    final sourceVehicles = [
      Vehicle(
        id: 'vehicle-electric',
        name: '电车',
        type: VehicleType.electric,
        initialOdometerKm: 1000,
      ),
      Vehicle(
        id: 'vehicle-hybrid',
        name: '插混',
        type: VehicleType.hybrid,
        initialOdometerKm: 1000,
      ),
    ];
    for (final vehicle in sourceVehicles) {
      await repository.saveVehicle(vehicle);
    }
    await repository.saveRecord(
      EnergyRecord.charge(
        id: 'charge-1',
        vehicleId: 'vehicle-electric',
        date: DateTime(2026),
        odometerKm: 1100,
        kwh: 40,
        unitPrice: 0.6,
        chargeMode: ChargeMode.fast,
      ),
    );
    await repository.saveRecord(
      EnergyRecord.hybrid(
        id: 'hybrid-1',
        vehicleId: 'vehicle-hybrid',
        date: DateTime(2026),
        odometerKm: 1200,
        liters: 18,
        fuelUnitPrice: 7.5,
        kwh: 12,
        electricityUnitPrice: 0.6,
      ),
    );

    final backup = await repository.exportBackup();
    final targetDatabase = AppDatabase.inMemory();
    final targetRepository = FuelRepository(targetDatabase);
    addTearDown(targetDatabase.close);

    await targetRepository.importBackup(backup);

    final importedCharge = (await targetRepository.getRecords(
      'vehicle-electric',
    )).single;
    final importedHybrid = (await targetRepository.getRecords(
      'vehicle-hybrid',
    )).single;

    expect(importedCharge.energyType, EnergyType.charge);
    expect(importedCharge.kwh, 40);
    expect(importedCharge.chargeMode, ChargeMode.fast);
    expect(importedHybrid.energyType, EnergyType.hybrid);
    expect(importedHybrid.fuelLiters, 18);
    expect(importedHybrid.kwh, 12);
    expect(importedHybrid.totalCost, closeTo(142.2, 0.001));
  });

  test('validateBackup rejects duplicate record ids', () async {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      name: '测试车',
      type: VehicleType.fuel,
      initialOdometerKm: 0,
    );
    final record = EnergyRecord.fuel(
      id: 'record-1',
      vehicleId: vehicle.id,
      date: DateTime(2026),
      odometerKm: 100,
      liters: 10,
      unitPrice: 7,
      isFull: true,
    );

    await expectLater(
      repository.validateBackup(
        BackupData(
          schemaVersion: 1,
          exportedAt: DateTime(2026),
          vehicles: [vehicle],
          records: [record, record],
        ),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('补能记录 ID 重复'),
        ),
      ),
    );
  });
}
