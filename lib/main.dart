import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/app.dart';
import 'package:fuel_consumption/src/data/repository_provider.dart';
import 'package:fuel_consumption/src/presentation/app_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        appRepositoryProvider.overrideWith(
          (ref) => ref.watch(localRepositoryProvider),
        ),
      ],
      child: const FuelConsumptionApp(),
    ),
  );
}
