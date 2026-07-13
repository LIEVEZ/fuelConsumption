import 'dart:convert';

import 'package:fuel_consumption/src/application/backup/backup_data.dart';
import 'package:fuel_consumption/src/application/backup/backup_schema.dart';
import 'package:fuel_consumption/src/application/backup/backup_serializers.dart';

class BackupCodec {
  static const currentSchemaVersion = BackupSchema.currentVersion;

  String encode(BackupData data) {
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': data.schemaVersion,
      'exportedAt': data.exportedAt.toIso8601String(),
      'vehicles': data.vehicles.map(vehicleToJson).toList(),
      'records': data.records.map(energyRecordToJson).toList(),
      'maintenanceRecords': data.maintenanceRecords
          .map(maintenanceRecordToJson)
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
          _optionalInt(decoded, 'schemaVersion') ?? currentSchemaVersion;
      if (schemaVersion != currentSchemaVersion) {
        throw FormatException('不支持的备份版本: $schemaVersion');
      }
      final exportedAt = _requiredDateTime(decoded, 'exportedAt');
      final vehicles = _requiredObjectList(decoded, 'vehicles');
      final records = _requiredObjectList(decoded, 'records');
      final maintenanceRecords = _optionalObjectList(
        decoded,
        'maintenanceRecords',
      );
      return BackupData(
        schemaVersion: schemaVersion,
        exportedAt: exportedAt,
        vehicles: _decodeObjects(vehicles, 'vehicles', vehicleFromJson),
        records: _decodeObjects(records, 'records', energyRecordFromJson),
        maintenanceRecords: _decodeObjects(
          maintenanceRecords,
          'maintenanceRecords',
          maintenanceRecordFromJson,
        ),
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

  DateTime _requiredDateTime(Map<String, Object?> json, String key) {
    final value = _requiredString(json, key);
    final date = DateTime.tryParse(value);
    if (date != null) {
      return date;
    }
    throw FormatException('$key 必须是有效日期字符串');
  }

  int? _optionalInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    throw FormatException('字段 $key 必须是整数');
  }

  List<Map<String, Object?>> _requiredObjectList(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) {
      throw FormatException('备份缺少字段: $key');
    }
    if (value is! List<Object?>) {
      throw FormatException('字段 $key 必须是数组');
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

  List<T> _decodeObjects<T>(
    List<Map<String, Object?>> source,
    String key,
    T Function(Map<String, Object?> json, String path) decode,
  ) {
    return [
      for (var index = 0; index < source.length; index++)
        decode(source[index], '$key[$index]'),
    ];
  }
}
