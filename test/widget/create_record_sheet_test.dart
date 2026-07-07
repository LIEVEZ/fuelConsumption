import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/presentation/dashboard_navigation.dart';
import 'package:fuel_consumption/src/widgets/create_record_sheet.dart';

void main() {
  testWidgets('returns energy action from fuel create sheet', (tester) async {
    CreateRecordAction? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                selectedAction = await showModalBottomSheet<CreateRecordAction>(
                  context: context,
                  builder: (context) =>
                      const CreateRecordSheet(vehicleType: VehicleType.fuel),
                );
              },
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('加油'));
    await tester.pumpAndSettle();

    expect(selectedAction, CreateRecordAction.energy);
  });

  testWidgets('shows vehicle-specific energy option labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CreateRecordSheet(vehicleType: VehicleType.electric),
              CreateRecordSheet(vehicleType: VehicleType.hybrid),
            ],
          ),
        ),
      ),
    );

    expect(find.text('充电'), findsOneWidget);
    expect(find.text('记录本次充电电量和费用'), findsOneWidget);
    expect(find.text('油电补能'), findsOneWidget);
    expect(find.text('记录本次燃油和充电费用'), findsOneWidget);
  });

  testWidgets('returns maintenance action from create sheet', (tester) async {
    CreateRecordAction? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                selectedAction = await showModalBottomSheet<CreateRecordAction>(
                  context: context,
                  builder: (context) => const CreateRecordSheet(),
                );
              },
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保养'));
    await tester.pumpAndSettle();

    expect(selectedAction, CreateRecordAction.maintenance);
  });
}
