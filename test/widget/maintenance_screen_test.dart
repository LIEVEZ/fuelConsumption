import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/maintenance_screen.dart';

void main() {
  testWidgets('saves a valid maintenance record with selected category', (
    tester,
  ) async {
    MaintenanceRecordInput? savedInput;
    var onSavedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaintenanceScreen(
            vehicle: _vehicle(),
            onSave: (input) async {
              savedInput = input;
              return MaintenanceRecord(
                id: 'saved-maintenance',
                vehicleId: input.vehicleId,
                date: input.date,
                category: input.category,
                cost: double.parse(input.costText),
                shop: input.shopText,
                note: input.noteText,
              );
            },
            onSaved: () => onSavedCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('保养类别'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('换轮胎'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '688.5');
    await tester.enterText(fields.at(1), '城北汽修');
    await tester.enterText(fields.at(2), '前轮两条');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(savedInput, isNotNull);
    expect(savedInput!.vehicleId, 'vehicle-1');
    expect(savedInput!.category, MaintenanceCategory.tire);
    expect(savedInput!.costText, '688.5');
    expect(savedInput!.shopText, '城北汽修');
    expect(savedInput!.noteText, '前轮两条');
    expect(onSavedCalled, isTrue);
  });

  testWidgets('shows an error and skips save for invalid cost', (tester) async {
    var saveCalled = false;
    var onSavedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaintenanceScreen(
            vehicle: _vehicle(),
            onSave: (_) async {
              saveCalled = true;
              throw const FormatException('请填写有效保养费用');
            },
            onSaved: () => onSavedCalled = true,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('请填写有效保养费用'), findsOneWidget);
    expect(saveCalled, isTrue);
    expect(onSavedCalled, isFalse);
  });
}

Vehicle _vehicle() {
  return const Vehicle(
    id: 'vehicle-1',
    name: '家用车',
    type: VehicleType.fuel,
    initialOdometerKm: 12000,
  );
}
