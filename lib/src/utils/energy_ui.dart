import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/legacy_refuel_note_parser.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/record_amounts.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';

IconData vehicleIcon(VehicleType type) {
  return switch (type) {
    VehicleType.fuel => Icons.directions_car,
    VehicleType.electric => Icons.electric_car,
    VehicleType.hybrid => Icons.ev_station,
    VehicleType.motorcycle => Icons.two_wheeler,
  };
}

IconData energyIcon(EnergyType type) {
  return switch (type) {
    EnergyType.fuel => Icons.local_gas_station,
    EnergyType.charge => Icons.bolt,
    EnergyType.hybrid => Icons.sync_alt,
  };
}

IconData maintenanceIcon(MaintenanceCategory category) {
  return switch (category) {
    MaintenanceCategory.regular => Icons.build_circle_outlined,
    MaintenanceCategory.oil => Icons.oil_barrel_outlined,
    MaintenanceCategory.tire => Icons.album_outlined,
    MaintenanceCategory.repair => Icons.handyman_outlined,
    MaintenanceCategory.wash => Icons.local_car_wash_outlined,
    MaintenanceCategory.insurance => Icons.verified_user_outlined,
    MaintenanceCategory.other => Icons.more_horiz,
  };
}

Color energyColor(EnergyType type) {
  return switch (type) {
    EnergyType.fuel => AppColors.fuel,
    EnergyType.charge => AppColors.charge,
    EnergyType.hybrid => AppColors.hybrid,
  };
}

String shortDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}/$month/$day';
}

String shortTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String recordSubtitle(EnergyRecord record) {
  final amount = switch (record.energyType) {
    EnergyType.fuel =>
      '${(record.fuelLiters ?? record.amount).toStringAsFixed(2)} L',
    EnergyType.charge =>
      '${(record.kwh ?? record.amount).toStringAsFixed(2)} kWh',
    EnergyType.hybrid =>
      '油 ${(record.fuelLiters ?? 0).toStringAsFixed(2)} L · 电 ${(record.kwh ?? 0).toStringAsFixed(2)} kWh',
  };
  final note = LegacyRefuelNoteParser.visibleNote(record.note);
  if (note.isEmpty) {
    return amount;
  }
  return '$amount · $note';
}

String? fuelPaymentSummary(EnergyRecord record) {
  if (record.energyType != EnergyType.fuel) {
    return null;
  }

  final discount = RecordAmounts.discountFrom(record);
  final parts = [
    if (record.machineAmount != null && record.machineAmount! > 0)
      '机显 ${record.machineAmount!.toStringAsFixed(2)} 元',
    if (discount > 0) '优惠 ${discount.toStringAsFixed(2)} 元',
    if (record.paidAmount != null && record.paidAmount! > 0)
      '实付 ${record.paidAmount!.toStringAsFixed(2)} 元',
  ];
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' · ');
}

double? parseLeadingNumber(String value) {
  final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
  if (match == null) return null;
  return double.tryParse(match.group(0)!);
}
