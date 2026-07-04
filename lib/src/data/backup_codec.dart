import 'dart:convert';

import 'package:fuel_consumption/src/domain/models.dart';

class BackupCodec {
  static const currentSchemaVersion = 1;

  String encode(BackupData data) {
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': data.schemaVersion,
      'exportedAt': data.exportedAt.toIso8601String(),
      'vehicles': data.vehicles.map((vehicle) => vehicle.toJson()).toList(),
      'records': data.records.map((record) => record.toJson()).toList(),
    });
  }

  BackupData decode(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    final schemaVersion = json['schemaVersion'] as int? ?? currentSchemaVersion;
    if (schemaVersion != currentSchemaVersion) {
      throw FormatException('不支持的备份版本: $schemaVersion');
    }
    return BackupData(
      schemaVersion: schemaVersion,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      vehicles: (json['vehicles'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Vehicle.fromJson)
          .toList(),
      records: (json['records'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(EnergyRecord.fromJson)
          .toList(),
    );
  }
}
