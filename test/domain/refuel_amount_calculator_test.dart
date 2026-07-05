import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/refuel_amount_calculator.dart';

void main() {
  test('syncs machine amount from unit price and liters', () {
    final values = RefuelAmountCalculator.syncMachineFields(
      _values(unitPrice: 7.25, liters: 20),
      RefuelMachineField.unitPrice,
    );

    expect(values.machineAmount, 145);
  });

  test('syncs liters from machine amount and unit price', () {
    final values = RefuelAmountCalculator.syncMachineFields(
      _values(unitPrice: 8, machineAmount: 160),
      RefuelMachineField.amount,
    );

    expect(values.liters, 20);
  });

  test('syncs paid amount and paid unit price from discount', () {
    final values = RefuelAmountCalculator.syncPaymentFields(
      _values(liters: 20, machineAmount: 160, discount: 20),
      RefuelPaymentField.discount,
    );

    expect(values.paidAmount, 140);
    expect(values.paidUnitPrice, 7);
  });

  test('syncs discount from paid amount', () {
    final values = RefuelAmountCalculator.syncPaymentFields(
      _values(liters: 20, machineAmount: 160, paidAmount: 130),
      RefuelPaymentField.paidAmount,
    );

    expect(values.discount, 30);
    expect(values.paidUnitPrice, 6.5);
  });

  test('syncs paid amount and discount from paid unit price', () {
    final values = RefuelAmountCalculator.syncPaymentFields(
      _values(liters: 20, machineAmount: 160, paidUnitPrice: 6),
      RefuelPaymentField.paidUnitPrice,
    );

    expect(values.paidAmount, 120);
    expect(values.discount, 40);
  });

  test('formats zero as a money placeholder', () {
    expect(RefuelAmountCalculator.formatAmount(0), '0.00');
  });
}

RefuelAmountValues _values({
  double unitPrice = 0,
  double liters = 0,
  double machineAmount = 0,
  double paidUnitPrice = 0,
  double discount = 0,
  double paidAmount = 0,
}) {
  return RefuelAmountValues(
    unitPrice: unitPrice,
    liters: liters,
    machineAmount: machineAmount,
    paidUnitPrice: paidUnitPrice,
    discount: discount,
    paidAmount: paidAmount,
  );
}
