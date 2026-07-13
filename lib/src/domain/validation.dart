import 'package:fuel_consumption/src/domain/models.dart';

class ValidationResult {
  const ValidationResult.valid() : isValid = true, message = '';

  const ValidationResult.invalid(this.message) : isValid = false;

  final bool isValid;
  final String message;
}

class RecordValidator {
  ValidationResult validate(
    EnergyRecord record,
    List<EnergyRecord> previousRecords,
  ) {
    final amountInvalid = switch (record.energyType) {
      EnergyType.fuel => (record.fuelLiters ?? record.amount) <= 0,
      EnergyType.charge => (record.kwh ?? record.amount) <= 0,
      EnergyType.hybrid =>
        (record.fuelLiters ?? 0) < 0 ||
            (record.kwh ?? 0) < 0 ||
            ((record.fuelLiters ?? 0) == 0 && (record.kwh ?? 0) == 0),
    };
    if (amountInvalid) {
      return const ValidationResult.invalid('能源数量必须大于 0');
    }
    if (record.totalCost <= 0 ||
        record.unitPrice < 0 ||
        (record.fuelUnitPrice ?? 0) < 0 ||
        (record.electricityUnitPrice ?? 0) < 0 ||
        (record.machineAmount ?? 0) < 0 ||
        (record.paidAmount ?? 0) < 0 ||
        (record.discountAmount ?? 0) < 0) {
      return const ValidationResult.invalid('金额必须大于 0');
    }

    final sameVehicle =
        previousRecords
            .where((item) => item.vehicleId == record.vehicleId)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    if (sameVehicle.any(
      (item) => item.id != record.id && item.date == record.date,
    )) {
      return const ValidationResult.invalid('同一时间已有补能记录');
    }
    final earlier = sameVehicle
        .where((item) => item.date.isBefore(record.date))
        .toList();
    final later = sameVehicle
        .where((item) => item.date.isAfter(record.date))
        .toList();
    if (earlier.isNotEmpty && record.odometerKm <= earlier.last.odometerKm) {
      return const ValidationResult.invalid('里程必须大于上一条记录');
    }
    if (later.isNotEmpty && record.odometerKm >= later.first.odometerKm) {
      return const ValidationResult.invalid('里程必须小于下一条记录');
    }

    return const ValidationResult.valid();
  }
}

class MaintenanceRecordValidator {
  ValidationResult validate(MaintenanceRecord record) {
    if (record.cost <= 0) {
      return const ValidationResult.invalid('保养费用必须大于 0');
    }
    return const ValidationResult.valid();
  }
}
