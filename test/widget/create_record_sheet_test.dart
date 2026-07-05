import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/widgets/create_record_sheet.dart';

void main() {
  testWidgets('returns refuel action from create sheet', (tester) async {
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
    await tester.tap(find.text('加油'));
    await tester.pumpAndSettle();

    expect(selectedAction, CreateRecordAction.refuel);
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
