import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/application/vehicle_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/widgets/dialogs/vehicle_dialog.dart';

void main() {
  testWidgets('validates required vehicle name before save', (tester) async {
    var saveCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VehicleDialog(
            onSave: (_) async {
              saveCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('保存车辆'));
    await tester.pumpAndSettle();

    expect(find.text('请填写车辆名称'), findsOneWidget);
    expect(saveCalled, isFalse);
  });

  testWidgets('returns a vehicle draft to the caller', (tester) async {
    VehicleDraft? savedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VehicleDialog(
            onSave: (draft) async {
              savedDraft = draft;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), '通勤车');
    await tester.enterText(find.byType(TextField).at(1), '轿车');
    await tester.enterText(find.byType(TextField).at(2), '12345');
    await tester.tap(find.text('电车'));
    await tester.tap(find.text('保存车辆'));
    await tester.pumpAndSettle();

    expect(savedDraft, isNotNull);
    expect(savedDraft!.name, '通勤车');
    expect(savedDraft!.model, '轿车');
    expect(savedDraft!.initialOdometerKm, 12345);
    expect(savedDraft!.type, VehicleType.electric);
  });
}
