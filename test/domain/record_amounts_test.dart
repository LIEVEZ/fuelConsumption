import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/record_amounts.dart';

void main() {
  test('prefers structured discount values over note text', () {
    final record = _record(
      note: '优惠 1.00 元',
      machineAmount: 200,
      paidAmount: 178.6,
      discountAmount: 21.4,
    );

    expect(RecordAmounts.discountFrom(record), closeTo(21.4, 0.001));
  });

  test('derives discount from structured machine and paid amounts', () {
    final record = _record(note: '', machineAmount: 200, paidAmount: 178.6);

    expect(RecordAmounts.discountFrom(record), closeTo(21.40, 0.001));
  });

  test('reads explicit discount from note', () {
    final record = _record(note: '机显金额 200.00 元 · 优惠 20.50 元');

    expect(RecordAmounts.discountFrom(record), 20.50);
  });

  test('derives discount from machine and paid amounts', () {
    final record = _record(note: '机显金额 200.00 元 · 实付金额 178.60 元');

    expect(RecordAmounts.discountFrom(record), closeTo(21.40, 0.001));
  });

  test('sums discounts across records', () {
    final records = [
      _record(id: 'record-1', note: '优惠 10.00 元'),
      _record(id: 'record-2', note: '机显金额 100.00 元 · 实付金额 95.00 元'),
    ];

    expect(RecordAmounts.totalDiscount(records), 15);
  });
}

EnergyRecord _record({
  String id = 'record-1',
  required String note,
  double? machineAmount,
  double? paidAmount,
  double? discountAmount,
}) {
  return EnergyRecord.fuel(
    id: id,
    vehicleId: 'vehicle-1',
    date: DateTime(2026),
    odometerKm: 100,
    liters: 10,
    unitPrice: 7,
    isFull: true,
    machineAmount: machineAmount,
    paidAmount: paidAmount,
    discountAmount: discountAmount,
    note: note,
  );
}
