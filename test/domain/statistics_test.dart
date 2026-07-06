import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/statistics.dart';

void main() {
  test('calculates electric consumption from charging records', () {
    final snapshot = EnergyStatisticsCalculator().build(
      const Vehicle(
        id: 'vehicle-1',
        name: '电车',
        type: VehicleType.electric,
        initialOdometerKm: 1000,
      ),
      [
        EnergyRecord.charge(
          id: 'record-1',
          vehicleId: 'vehicle-1',
          date: DateTime(2026, 7, 1),
          odometerKm: 1100,
          kwh: 20,
          unitPrice: 0.5,
          chargeMode: ChargeMode.slow,
        ),
        EnergyRecord.charge(
          id: 'record-2',
          vehicleId: 'vehicle-1',
          date: DateTime(2026, 7, 5),
          odometerKm: 1300,
          kwh: 40,
          unitPrice: 0.5,
          chargeMode: ChargeMode.fast,
        ),
      ],
    );

    expect(snapshot.averageConsumptionLabel, '20.00 kWh/100km');
    expect(snapshot.latestConsumptionLabel, '20.00 kWh/100km');
    expect(snapshot.totalCost, 30);
    expect(snapshot.costPerKm, 0.1);
    expect(snapshot.totalDistanceKm, 300);
  });

  test('calculates hybrid fuel and electricity consumption together', () {
    final snapshot = EnergyStatisticsCalculator().build(
      const Vehicle(
        id: 'vehicle-1',
        name: '插混',
        type: VehicleType.hybrid,
        initialOdometerKm: 1000,
      ),
      [
        EnergyRecord.hybrid(
          id: 'record-1',
          vehicleId: 'vehicle-1',
          date: DateTime(2026, 7, 5),
          odometerKm: 1200,
          liters: 10,
          fuelUnitPrice: 7,
          kwh: 20,
          electricityUnitPrice: 0.5,
        ),
      ],
    );

    expect(
      snapshot.averageConsumptionLabel,
      '油 5.00 L/100km · 电 10.00 kWh/100km',
    );
    expect(snapshot.latestConsumptionLabel, '总成本 0.40 元/km');
    expect(snapshot.totalCost, 80);
    expect(snapshot.costPerKm, 0.4);
    expect(snapshot.totalDistanceKm, 200);
  });
}
