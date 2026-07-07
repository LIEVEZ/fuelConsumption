import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/hybrid_screen.dart';

void main() {
  testWidgets('saves a valid hybrid energy record', (tester) async {
    HybridRecordInput? savedInput;
    var onSavedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HybridScreen(
            vehicle: _vehicle(),
            records: [_record(odometerKm: 12000)],
            onSave: (input) async {
              savedInput = input;
              return EnergyRecord.hybrid(
                id: 'saved-record',
                vehicleId: input.vehicleId,
                date: input.date,
                odometerKm: double.parse(input.odometerText),
                liters: double.parse(input.litersText),
                fuelUnitPrice: double.parse(input.fuelUnitPriceText),
                kwh: double.parse(input.kwhText),
                electricityUnitPrice: double.parse(
                  input.electricityUnitPriceText,
                ),
                note: input.noteText,
              );
            },
            onSaved: () => onSavedCalled = true,
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '12250');
    await tester.enterText(fields.at(1), '18');
    await tester.enterText(fields.at(2), '7.5');
    await tester.enterText(fields.at(3), '12');
    await tester.enterText(fields.at(4), '0.6');
    await tester.enterText(fields.at(5), '周末长途');
    await _tapSave(tester);

    expect(savedInput, isNotNull);
    expect(savedInput!.vehicleId, 'vehicle-1');
    expect(savedInput!.odometerText, '12250');
    expect(savedInput!.litersText, '18');
    expect(savedInput!.fuelUnitPriceText, '7.5');
    expect(savedInput!.kwhText, '12');
    expect(savedInput!.electricityUnitPriceText, '0.6');
    expect(savedInput!.noteText, '周末长途');
    expect(onSavedCalled, isTrue);
  });

  testWidgets('shows an error when both fuel and electricity are empty', (
    tester,
  ) async {
    var saveCalled = false;
    var onSavedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HybridScreen(
            vehicle: _vehicle(),
            records: [_record(odometerKm: 12000)],
            onSave: (_) async {
              saveCalled = true;
              throw const FormatException('请至少填写燃油或电量');
            },
            onSaved: () => onSavedCalled = true,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '12250');
    await _tapSave(tester);

    expect(find.text('请至少填写燃油或电量'), findsOneWidget);
    expect(saveCalled, isTrue);
    expect(onSavedCalled, isFalse);
  });
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -600));
  await tester.pumpAndSettle();
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();
}

Vehicle _vehicle() {
  return const Vehicle(
    id: 'vehicle-1',
    name: '插混',
    type: VehicleType.hybrid,
    initialOdometerKm: 12000,
  );
}

EnergyRecord _record({required double odometerKm}) {
  return EnergyRecord.hybrid(
    id: 'record-0',
    vehicleId: 'vehicle-1',
    date: DateTime(2026),
    odometerKm: odometerKm,
    liters: 10,
    fuelUnitPrice: 7,
    kwh: 20,
    electricityUnitPrice: 0.5,
  );
}
