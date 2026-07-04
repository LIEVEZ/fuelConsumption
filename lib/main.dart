import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/app.dart';
import 'package:fuel_consumption/src/data/app_database.dart';
import 'package:fuel_consumption/src/data/fuel_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FuelConsumptionApp(repository: FuelRepository(AppDatabase())));
}
