import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/data/app_database.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/fuel_repository.dart';

final repositoryProvider = Provider<AppRepository>((ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return FuelRepository(database);
});
