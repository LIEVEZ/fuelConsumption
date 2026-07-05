import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/refuel_screen.dart';

void main() {
  testWidgets('uses the latest record odometer as the default value', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RefuelScreen(
            vehicle: _vehicle(),
            records: [_record(id: 'record-1', odometerKm: 12345)],
            onSave: (_) async {},
            onSaved: () {},
          ),
        ),
      ),
    );

    final odometerField = tester.widget<TextField>(
      find.byType(TextField).at(0),
    );
    expect(odometerField.controller?.text, '12345');
  });

  testWidgets('saves a valid fuel record with the paid amount values', (
    tester,
  ) async {
    EnergyRecord? savedRecord;
    var onSavedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RefuelScreen(
            vehicle: _vehicle(),
            records: [_record(odometerKm: 12000)],
            onSave: (record) async => savedRecord = record,
            onSaved: () => onSavedCalled = true,
          ),
        ),
      ),
    );

    await _enterRefuelValues(tester, odometer: '12100');
    await tester.tap(find.text('油灯亮'));
    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(savedRecord, isNotNull);
    expect(savedRecord!.vehicleId, 'vehicle-1');
    expect(savedRecord!.odometerKm, 12100);
    expect(savedRecord!.fuelLiters, 20);
    expect(savedRecord!.unitPrice, 7);
    expect(savedRecord!.totalCost, 140);
    expect(savedRecord!.note, contains('油灯亮'));
    expect(savedRecord!.note, contains('92#汽油'));
    expect(onSavedCalled, isTrue);
  });

  testWidgets('shows validation error and skips save for invalid odometer', (
    tester,
  ) async {
    var saveCalled = false;
    var onSavedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RefuelScreen(
            vehicle: _vehicle(),
            records: [_record(odometerKm: 12000)],
            onSave: (_) async => saveCalled = true,
            onSaved: () => onSavedCalled = true,
          ),
        ),
      ),
    );

    await _enterRefuelValues(tester, odometer: '11900');
    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('里程必须大于上一条记录'), findsOneWidget);
    expect(saveCalled, isFalse);
    expect(onSavedCalled, isFalse);
  });
}

Future<void> _enterRefuelValues(
  WidgetTester tester, {
  required String odometer,
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), odometer);
  await tester.enterText(fields.at(1), '8');
  await tester.enterText(fields.at(2), '20');
  await tester.enterText(fields.at(5), '20');
  await tester.pump();
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -500));
  await tester.pumpAndSettle();
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();
}

Vehicle _vehicle() {
  return const Vehicle(
    id: 'vehicle-1',
    name: '家用车',
    type: VehicleType.fuel,
    initialOdometerKm: 12000,
  );
}

EnergyRecord _record({String id = 'record-0', double odometerKm = 12000}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: 'vehicle-1',
    date: DateTime(2026),
    odometerKm: odometerKm,
    liters: 10,
    unitPrice: 7,
    isFull: true,
  );
}
