import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/energy_record_screen.dart';

void main() {
  testWidgets('routes fuel vehicles to the refuel form', (tester) async {
    await _pumpEnergyScreen(tester, VehicleType.fuel);

    expect(find.text('加油日期'), findsOneWidget);
    expect(find.text('充电记录'), findsNothing);
    expect(find.text('油电补能'), findsNothing);
  });

  testWidgets('routes motorcycles to the refuel form', (tester) async {
    await _pumpEnergyScreen(tester, VehicleType.motorcycle);

    expect(find.text('加油日期'), findsOneWidget);
    expect(find.text('充电记录'), findsNothing);
    expect(find.text('油电补能'), findsNothing);
  });

  testWidgets('routes electric vehicles to the charge form', (tester) async {
    await _pumpEnergyScreen(tester, VehicleType.electric);

    expect(find.text('充电记录'), findsOneWidget);
    expect(find.text('充电电量'), findsOneWidget);
  });

  testWidgets('routes hybrid vehicles to the hybrid form', (tester) async {
    await _pumpEnergyScreen(tester, VehicleType.hybrid);

    expect(find.text('油电补能'), findsOneWidget);
    expect(find.text('加油量'), findsOneWidget);
    expect(find.text('充电电量'), findsOneWidget);
  });
}

Future<void> _pumpEnergyScreen(
  WidgetTester tester,
  VehicleType vehicleType,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: EnergyRecordScreen(
          vehicle: Vehicle(
            id: 'vehicle-1',
            name: vehicleType.label,
            type: vehicleType,
            initialOdometerKm: 1000,
          ),
          records: const [],
          onSaveRefuel: (input) async => _dummyRefuelRecord(input),
          onSaveCharge: (input) async => _dummyChargeRecord(input),
          onSaveHybrid: (input) async => _dummyHybridRecord(input),
          onSaved: () {},
        ),
      ),
    ),
  );
}

EnergyRecord _dummyRefuelRecord(RefuelRecordInput input) {
  return EnergyRecord.fuel(
    id: 'saved-refuel',
    vehicleId: input.vehicleId,
    date: input.date,
    odometerKm: 1000,
    liters: 10,
    unitPrice: 7,
    isFull: true,
  );
}

EnergyRecord _dummyChargeRecord(ChargeRecordInput input) {
  return EnergyRecord.charge(
    id: 'saved-charge',
    vehicleId: input.vehicleId,
    date: input.date,
    odometerKm: 1000,
    kwh: 10,
    unitPrice: 0.5,
    chargeMode: input.chargeMode,
  );
}

EnergyRecord _dummyHybridRecord(HybridRecordInput input) {
  return EnergyRecord.hybrid(
    id: 'saved-hybrid',
    vehicleId: input.vehicleId,
    date: input.date,
    odometerKm: 1000,
    liters: 10,
    fuelUnitPrice: 7,
    kwh: 10,
    electricityUnitPrice: 0.5,
  );
}
