import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/screens/refuel_form_controller.dart';

void main() {
  test('syncs machine amount and paid amount fields from two inputs', () {
    final form = RefuelFormController(initialOdometerKm: 12000);
    addTearDown(form.dispose);

    form.unitPriceController.text = '7';
    form.litersController.text = '20';

    expect(form.machineAmountController.text, '140.00');
    expect(form.paidAmountController.text, '140.00');
    expect(form.paidUnitPriceController.text, '7.00');

    form.paidAmountController.text = '120';

    expect(form.discountController.text, '20.00');
    expect(form.paidUnitPriceController.text, '6.00');
  });

  test('builds a refuel record draft from current field values', () {
    final form = RefuelFormController(initialOdometerKm: 12000);
    addTearDown(form.dispose);

    form.odometerController.text = '12100';
    form.unitPriceController.text = '7';
    form.litersController.text = '20';
    form.discountController.text = '10';

    final draft = form.buildDraft(
      id: 'record-1',
      vehicleId: 'vehicle-1',
      date: DateTime(2026, 7, 5, 9, 30),
      isFull: true,
      warningLightOn: true,
      fuelGrade: '95#汽油',
    );

    expect(draft.id, 'record-1');
    expect(draft.vehicleId, 'vehicle-1');
    expect(draft.odometerText, '12100');
    expect(draft.machineAmountText, '140.00');
    expect(draft.discountText, '10');
    expect(draft.paidAmountText, '130.00');
    expect(draft.warningLightOn, isTrue);
    expect(draft.fuelGrade, '95#汽油');
  });
}
