import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

LazyDatabase openDatabaseConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, 'fuel_consumption.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

QueryExecutor openInMemoryDatabaseConnection() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return NativeDatabase.memory();
}
