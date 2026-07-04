import 'package:collection/collection.dart';
import 'package:fuel_consumption/src/domain/models.dart';

class EnergyStatisticsCalculator {
  StatisticsSnapshot build(Vehicle vehicle, List<EnergyRecord> input) {
    final records = [...input]..sortBy((record) => record.date);
    final totalCost = records.fold<double>(
      0,
      (sum, record) => sum + record.totalCost,
    );
    final lastOdometer = records.isEmpty
        ? vehicle.initialOdometerKm
        : records.last.odometerKm;
    final distance = (lastOdometer - vehicle.initialOdometerKm)
        .clamp(0, double.infinity)
        .toDouble();
    final costPerKm = distance == 0 ? 0.0 : totalCost / distance;

    return switch (vehicle.type) {
      VehicleType.fuel || VehicleType.motorcycle => _fuelSnapshot(
        records,
        totalCost,
        costPerKm,
        distance,
      ),
      VehicleType.electric => _electricSnapshot(
        records,
        totalCost,
        costPerKm,
        distance,
        vehicle.initialOdometerKm,
      ),
      VehicleType.hybrid => _hybridSnapshot(
        records,
        totalCost,
        costPerKm,
        distance,
      ),
    };
  }

  StatisticsSnapshot _fuelSnapshot(
    List<EnergyRecord> records,
    double totalCost,
    double costPerKm,
    double distance,
  ) {
    final fullRecords = records.where((record) => record.isFull).toList();
    if (fullRecords.length < 2) {
      return StatisticsSnapshot(
        averageConsumptionLabel: '待两次加满后计算',
        latestConsumptionLabel: '暂无有效油耗',
        totalCost: totalCost,
        costPerKm: costPerKm,
        totalDistanceKm: distance,
      );
    }

    final first = fullRecords.first;
    final last = fullRecords.last;
    final stageDistance = last.odometerKm - first.odometerKm;
    final fuelAfterFirst = fullRecords
        .skip(1)
        .fold<double>(
          0,
          (sum, record) => sum + (record.fuelLiters ?? record.amount),
        );
    final average = stageDistance <= 0
        ? 0
        : fuelAfterFirst / stageDistance * 100;
    final latestPrevious = fullRecords[fullRecords.length - 2];
    final latestDistance = last.odometerKm - latestPrevious.odometerKm;
    final latest = latestDistance <= 0
        ? 0
        : (last.fuelLiters ?? last.amount) / latestDistance * 100;

    return StatisticsSnapshot(
      averageConsumptionLabel: '${average.toStringAsFixed(2)} L/100km',
      latestConsumptionLabel: '${latest.toStringAsFixed(2)} L/100km',
      totalCost: totalCost,
      costPerKm: costPerKm,
      totalDistanceKm: distance,
    );
  }

  StatisticsSnapshot _electricSnapshot(
    List<EnergyRecord> records,
    double totalCost,
    double costPerKm,
    double distance,
    double initialOdometerKm,
  ) {
    final effectiveDistance = records.length < 2
        ? distance
        : records.last.odometerKm - records.first.odometerKm;
    final effectiveKwh = records.length < 2
        ? records.fold<double>(
            0,
            (sum, record) => sum + (record.kwh ?? record.amount),
          )
        : records
              .skip(1)
              .fold<double>(
                0,
                (sum, record) => sum + (record.kwh ?? record.amount),
              );
    final average = effectiveDistance == 0
        ? 0
        : effectiveKwh / effectiveDistance * 100;
    final latest = records.isEmpty
        ? 0
        : records.last.kwh ?? records.last.amount;
    final previousOdometer = records.length < 2
        ? initialOdometerKm
        : records[records.length - 2].odometerKm;
    final latestDistance = records.isEmpty
        ? 0.0
        : records.last.odometerKm - previousOdometer;
    final latestConsumption = latestDistance <= 0
        ? average
        : latest / latestDistance * 100;

    return StatisticsSnapshot(
      averageConsumptionLabel: '${average.toStringAsFixed(2)} kWh/100km',
      latestConsumptionLabel:
          '${latestConsumption.toStringAsFixed(2)} kWh/100km',
      totalCost: totalCost,
      costPerKm: costPerKm,
      totalDistanceKm: distance,
    );
  }

  StatisticsSnapshot _hybridSnapshot(
    List<EnergyRecord> records,
    double totalCost,
    double costPerKm,
    double distance,
  ) {
    final totalFuel = records.fold<double>(
      0,
      (sum, record) => sum + (record.fuelLiters ?? 0),
    );
    final totalKwh = records.fold<double>(
      0,
      (sum, record) => sum + (record.kwh ?? 0),
    );
    final fuel = distance == 0 ? 0 : totalFuel / distance * 100;
    final electricity = distance == 0 ? 0 : totalKwh / distance * 100;

    return StatisticsSnapshot(
      averageConsumptionLabel:
          '油 ${fuel.toStringAsFixed(2)} L/100km · 电 ${electricity.toStringAsFixed(2)} kWh/100km',
      latestConsumptionLabel: '总成本 ${costPerKm.toStringAsFixed(2)} 元/km',
      totalCost: totalCost,
      costPerKm: costPerKm,
      totalDistanceKm: distance,
    );
  }
}
