import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/charge_screen.dart';

void main() {
  testWidgets('saves a valid fast charge record', (tester) async {
    ChargeRecordInput? savedInput;
    var onSavedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChargeScreen(
            vehicle: _vehicle(),
            records: [_record(odometerKm: 12000)],
            onSave: (input) async {
              savedInput = input;
              return EnergyRecord.charge(
                id: 'saved-record',
                vehicleId: input.vehicleId,
                date: input.date,
                odometerKm: double.parse(input.odometerText),
                kwh: double.parse(input.kwhText),
                unitPrice: double.parse(input.unitPriceText),
                chargeMode: input.chargeMode,
                note: input.noteText,
              );
            },
            onSaved: () => onSavedCalled = true,
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '12180');
    await tester.enterText(fields.at(1), '42');
    await tester.enterText(fields.at(2), '0.68');
    await tester.enterText(fields.at(3), '商场快充');
    await tester.ensureVisible(find.text('快充'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('快充'));
    await _tapSave(tester);

    expect(savedInput, isNotNull);
    expect(savedInput!.vehicleId, 'vehicle-1');
    expect(savedInput!.odometerText, '12180');
    expect(savedInput!.kwhText, '42');
    expect(savedInput!.unitPriceText, '0.68');
    expect(savedInput!.chargeMode, ChargeMode.fast);
    expect(savedInput!.noteText, '商场快充');
    expect(onSavedCalled, isTrue);
  });

  testWidgets('shows an error returned by record command', (tester) async {
    var saveCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChargeScreen(
            vehicle: _vehicle(),
            records: [_record(odometerKm: 12000)],
            onSave: (_) async {
              saveCalled = true;
              throw const FormatException('请填写有效充电电量');
            },
            onSaved: () {},
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '12180');
    await tester.enterText(fields.at(1), '0');
    await tester.enterText(fields.at(2), '0.68');
    await _tapSave(tester);

    expect(find.text('请填写有效充电电量'), findsOneWidget);
    expect(saveCalled, isTrue);
  });

  testWidgets('ignores duplicate taps while saving', (tester) async {
    final saveCompleter = Completer<EnergyRecord>();
    var saveCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChargeScreen(
            vehicle: _vehicle(),
            records: [_record(odometerKm: 12000)],
            onSave: (input) {
              saveCalls += 1;
              return saveCompleter.future;
            },
            onSaved: () {},
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '12180');
    await tester.enterText(fields.at(1), '42');
    await tester.enterText(fields.at(2), '0.68');
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('保存'));
    await tester.tap(find.text('保存'));
    await tester.pump();

    expect(saveCalls, 1);

    saveCompleter.complete(
      EnergyRecord.charge(
        id: 'saved-record',
        vehicleId: 'vehicle-1',
        date: DateTime(2026),
        odometerKm: 12180,
        kwh: 42,
        unitPrice: 0.68,
        chargeMode: ChargeMode.slow,
      ),
    );
    await tester.pumpAndSettle();
  });
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
    name: '电车',
    type: VehicleType.electric,
    initialOdometerKm: 12000,
  );
}

EnergyRecord _record({required double odometerKm}) {
  return EnergyRecord.charge(
    id: 'record-0',
    vehicleId: 'vehicle-1',
    date: DateTime(2026),
    odometerKm: odometerKm,
    kwh: 20,
    unitPrice: 0.5,
    chargeMode: ChargeMode.slow,
  );
}
