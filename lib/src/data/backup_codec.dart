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
      'maintenanceRecords': data.maintenanceRecords
          .map((record) => record.toJson())
          .toList(),
    });
  }

  BackupData decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('JSON 格式不正确，请检查是否完整复制');
    }

    try {
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('JSON 根节点必须是对象');
      }
      final schemaVersion =
          decoded['schemaVersion'] as int? ?? currentSchemaVersion;
      if (schemaVersion != currentSchemaVersion) {
        throw FormatException('不支持的备份版本: $schemaVersion');
      }
      return BackupData(
        schemaVersion: schemaVersion,
        exportedAt: DateTime.parse(_requiredString(decoded, 'exportedAt')),
        vehicles: _requiredObjectList(
          decoded,
          'vehicles',
        ).map(Vehicle.fromJson).toList(),
        records: _requiredObjectList(
          decoded,
          'records',
        ).map(EnergyRecord.fromJson).toList(),
        maintenanceRecords: _optionalObjectList(
          decoded,
          'maintenanceRecords',
        ).map(MaintenanceRecord.fromJson).toList(),
      );
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('备份内容不完整或字段格式不正确: $error');
    }
  }

  String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('备份缺少字段: $key');
  }

  List<Map<String, Object?>> _requiredObjectList(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! List<Object?>) {
      throw FormatException('备份缺少字段: $key');
    }
    return _castObjectList(value, key);
  }

  List<Map<String, Object?>> _optionalObjectList(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) {
      return const [];
    }
    if (value is! List<Object?>) {
      throw FormatException('字段 $key 必须是数组');
    }
    return _castObjectList(value, key);
  }

  List<Map<String, Object?>> _castObjectList(List<Object?> source, String key) {
    return [
      for (final item in source)
        if (item is Map<String, Object?>)
          item
        else
          throw FormatException('字段 $key 中包含非对象项'),
    ];
  }
}
