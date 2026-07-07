import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/widgets/expense/expense_detail_card.dart';

void main() {
  testWidgets(
    'shows structured refuel payment summary without legacy note noise',
    (tester) async {
      final record = EnergyRecord.fuel(
        id: 'record-1',
        vehicleId: 'vehicle-1',
        date: DateTime(2026, 7, 5),
        odometerKm: 12100,
        liters: 20,
        unitPrice: 7,
        isFull: true,
        machineAmount: 160,
        paidAmount: 140,
        discountAmount: 20,
        note: '油灯亮 · 机显金额 160.00 元 · 优惠 20.00 元 · 实付金额 140.00 元 · 95#汽油',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExpenseDetailCard(items: [ExpenseItem.energy(record)]),
            ),
          ),
        ),
      );

      expect(find.textContaining('机显 160.00 元'), findsOneWidget);
      expect(find.textContaining('优惠 20.00 元'), findsOneWidget);
      expect(find.textContaining('实付 140.00 元'), findsOneWidget);
      expect(find.textContaining('机显金额 160.00 元'), findsNothing);
      expect(find.textContaining('实付金额 140.00 元'), findsNothing);
    },
  );

  testWidgets('shows charge and hybrid energy details without fuel discounts', (
    tester,
  ) async {
    final charge = EnergyRecord.charge(
      id: 'charge-1',
      vehicleId: 'vehicle-1',
      date: DateTime(2026, 7, 5),
      odometerKm: 12100,
      kwh: 40,
      unitPrice: 0.6,
      chargeMode: ChargeMode.fast,
      note: '商场快充',
    );
    final hybrid = EnergyRecord.hybrid(
      id: 'hybrid-1',
      vehicleId: 'vehicle-1',
      date: DateTime(2026, 7, 6),
      odometerKm: 12300,
      liters: 18,
      fuelUnitPrice: 7.5,
      kwh: 12,
      electricityUnitPrice: 0.6,
      note: '周末长途',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExpenseDetailCard(
              items: [ExpenseItem.energy(charge), ExpenseItem.energy(hybrid)],
            ),
          ),
        ),
      ),
    );

    expect(find.text('充电'), findsOneWidget);
    expect(find.textContaining('40.00 kWh'), findsOneWidget);
    expect(find.text('油电'), findsOneWidget);
    expect(find.textContaining('油 18.00 L · 电 12.00 kWh'), findsOneWidget);
    expect(find.textContaining('机显'), findsNothing);
    expect(find.textContaining('优惠'), findsNothing);
    expect(find.textContaining('实付'), findsNothing);
  });
}
