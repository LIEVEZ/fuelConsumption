import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/fuel_grades.dart';
import 'package:fuel_consumption/src/domain/refuel_record_assembler.dart';

void main() {
  test('builds fuel record with paid amount unit price and note protocol', () {
    final result = RefuelRecordAssembler.assemble(
      _draft(
        unitPriceText: '8',
        litersText: '20',
        machineAmountText: '160',
        paidUnitPriceText: '7',
        discountText: '20',
        paidAmountText: '140',
        warningLightOn: true,
        noteText: '周末加油',
      ),
    );

    expect(result.isSuccess, isTrue);
    final record = result.record!;
    expect(record.fuelLiters, 20);
    expect(record.unitPrice, 7);
    expect(record.totalCost, 140);
    expect(record.machineAmount, 160);
    expect(record.paidAmount, 140);
    expect(record.discountAmount, 20);
    expect(record.note, contains('油灯亮'));
    expect(record.note, contains('机显单价 8.00 元/升'));
    expect(record.note, contains('机显金额 160.00 元'));
    expect(record.note, contains('优惠 20.00 元'));
    expect(record.note, contains('实付金额 140.00 元'));
    expect(record.note, contains(defaultFuelGrade));
    expect(record.note, contains('周末加油'));
  });

  test('reports missing odometer', () {
    final result = RefuelRecordAssembler.assemble(_draft(odometerText: ''));

    expect(result.isSuccess, isFalse);
    expect(result.error, '请填写当前里程');
  });

  test('reports non-positive paid amount', () {
    final result = RefuelRecordAssembler.assemble(
      _draft(litersText: '20', unitPriceText: '8', paidAmountText: '0'),
    );

    expect(result.isSuccess, isFalse);
    expect(result.error, '加油量、实付金额必须大于 0');
  });
}

RefuelRecordDraft _draft({
  String odometerText = '12000',
  String unitPriceText = '8',
  String litersText = '20',
  String machineAmountText = '160',
  String paidUnitPriceText = '7',
  String discountText = '20',
  String paidAmountText = '140',
  bool warningLightOn = false,
  String noteText = '',
}) {
  return RefuelRecordDraft(
    id: 'record-1',
    vehicleId: 'vehicle-1',
    date: DateTime(2026),
    odometerText: odometerText,
    unitPriceText: unitPriceText,
    litersText: litersText,
    machineAmountText: machineAmountText,
    paidUnitPriceText: paidUnitPriceText,
    discountText: discountText,
    paidAmountText: paidAmountText,
    isFull: true,
    warningLightOn: warningLightOn,
    fuelGrade: defaultFuelGrade,
    noteText: noteText,
  );
}
