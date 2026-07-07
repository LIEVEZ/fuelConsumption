import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/energy_record_assembler.dart';
import 'package:fuel_consumption/src/domain/models.dart';

void main() {
  test('assembles charge records from text fields', () {
    final result = EnergyRecordAssembler.assembleCharge(
      ChargeRecordDraft(
        id: 'record-1',
        vehicleId: 'vehicle-1',
        date: DateTime(2026),
        odometerText: '12000',
        kwhText: '42',
        unitPriceText: '0.68',
        chargeMode: ChargeMode.fast,
        noteText: ' 商场快充 ',
      ),
    );

    expect(result.isSuccess, isTrue);
    final record = result.record!;
    expect(record.energyType, EnergyType.charge);
    expect(record.odometerKm, 12000);
    expect(record.kwh, 42);
    expect(record.electricityUnitPrice, 0.68);
    expect(record.chargeMode, ChargeMode.fast);
    expect(record.totalCost, closeTo(28.56, 0.001));
    expect(record.note, '商场快充');
  });

  test('reports invalid charge values', () {
    final result = EnergyRecordAssembler.assembleCharge(
      _chargeDraft(kwhText: '0'),
    );

    expect(result.isSuccess, isFalse);
    expect(result.error, '请填写有效充电电量');
  });

  test('assembles hybrid records from text fields', () {
    final result = EnergyRecordAssembler.assembleHybrid(
      HybridRecordDraft(
        id: 'record-1',
        vehicleId: 'vehicle-1',
        date: DateTime(2026),
        odometerText: '12250',
        litersText: '18',
        fuelUnitPriceText: '7.5',
        kwhText: '12',
        electricityUnitPriceText: '0.6',
        noteText: ' 周末长途 ',
      ),
    );

    expect(result.isSuccess, isTrue);
    final record = result.record!;
    expect(record.energyType, EnergyType.hybrid);
    expect(record.odometerKm, 12250);
    expect(record.fuelLiters, 18);
    expect(record.fuelUnitPrice, 7.5);
    expect(record.kwh, 12);
    expect(record.electricityUnitPrice, 0.6);
    expect(record.totalCost, closeTo(142.2, 0.001));
    expect(record.note, '周末长途');
  });

  test('reports empty hybrid energy values', () {
    final result = EnergyRecordAssembler.assembleHybrid(
      _hybridDraft(litersText: '0', kwhText: '0'),
    );

    expect(result.isSuccess, isFalse);
    expect(result.error, '请至少填写燃油或电量');
  });
}

ChargeRecordDraft _chargeDraft({
  String odometerText = '12000',
  String kwhText = '42',
  String unitPriceText = '0.68',
}) {
  return ChargeRecordDraft(
    id: 'record-1',
    vehicleId: 'vehicle-1',
    date: DateTime(2026),
    odometerText: odometerText,
    kwhText: kwhText,
    unitPriceText: unitPriceText,
    chargeMode: ChargeMode.slow,
    noteText: '',
  );
}

HybridRecordDraft _hybridDraft({
  String odometerText = '12000',
  String litersText = '18',
  String fuelUnitPriceText = '7.5',
  String kwhText = '12',
  String electricityUnitPriceText = '0.6',
}) {
  return HybridRecordDraft(
    id: 'record-1',
    vehicleId: 'vehicle-1',
    date: DateTime(2026),
    odometerText: odometerText,
    litersText: litersText,
    fuelUnitPriceText: fuelUnitPriceText,
    kwhText: kwhText,
    electricityUnitPriceText: electricityUnitPriceText,
    noteText: '',
  );
}
