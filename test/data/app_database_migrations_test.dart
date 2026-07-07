import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/data/app_database.dart';

void main() {
  test('migrates legacy refuel amount notes into structured columns', () async {
    final timestamp = DateTime(2026).millisecondsSinceEpoch;
    final executor = NativeDatabase.memory(
      setup: (sqliteDb) {
        sqliteDb
          ..execute('''
            CREATE TABLE vehicle_rows (
              id TEXT NOT NULL PRIMARY KEY,
              name TEXT NOT NULL,
              type TEXT NOT NULL,
              initial_odometer_km REAL NOT NULL,
              model TEXT NOT NULL DEFAULT '',
              is_default INTEGER NOT NULL DEFAULT 0 CHECK ("is_default" IN (0, 1)),
              archived INTEGER NOT NULL DEFAULT 0 CHECK ("archived" IN (0, 1))
            );
          ''')
          ..execute('''
            CREATE TABLE energy_record_rows (
              id TEXT NOT NULL PRIMARY KEY,
              vehicle_id TEXT NOT NULL REFERENCES vehicle_rows (id),
              date INTEGER NOT NULL,
              odometer_km REAL NOT NULL,
              energy_type TEXT NOT NULL,
              amount REAL NOT NULL,
              unit_price REAL NOT NULL,
              total_cost REAL NOT NULL,
              is_full INTEGER NOT NULL DEFAULT 0 CHECK ("is_full" IN (0, 1)),
              fuel_liters REAL NULL,
              kwh REAL NULL,
              fuel_unit_price REAL NULL,
              electricity_unit_price REAL NULL,
              charge_mode TEXT NULL,
              note TEXT NOT NULL DEFAULT ''
            );
          ''')
          ..execute('''
            CREATE TABLE maintenance_record_rows (
              id TEXT NOT NULL PRIMARY KEY,
              vehicle_id TEXT NOT NULL REFERENCES vehicle_rows (id),
              date INTEGER NOT NULL,
              category TEXT NOT NULL,
              cost REAL NOT NULL,
              shop TEXT NOT NULL DEFAULT '',
              note TEXT NOT NULL DEFAULT ''
            );
          ''')
          ..execute('''
            INSERT INTO vehicle_rows (
              id, name, type, initial_odometer_km, model, is_default, archived
            ) VALUES (
              'vehicle-1', '家用车', 'fuel', 12000, '', 1, 0
            );
          ''')
          ..execute('''
            INSERT INTO energy_record_rows (
              id,
              vehicle_id,
              date,
              odometer_km,
              energy_type,
              amount,
              unit_price,
              total_cost,
              is_full,
              fuel_liters,
              fuel_unit_price,
              note
            ) VALUES (
              'record-1',
              'vehicle-1',
              $timestamp,
              12100,
              'fuel',
              20,
              7,
              140,
              1,
              20,
              7,
              '油灯亮 · 机显金额 160.00 元 · 优惠 20.00 元 · 实付金额 140.00 元 · 92#汽油'
            );
          ''')
          ..execute('PRAGMA user_version = 3;');
      },
    );
    final database = AppDatabase.withExecutor(executor);
    addTearDown(database.close);

    final records = await database.getRecords('vehicle-1');
    final record = records.single;

    expect(record.machineAmount, 160);
    expect(record.paidAmount, 140);
    expect(record.discountAmount, 20);
    expect(record.totalCost, 140);
  });
}
