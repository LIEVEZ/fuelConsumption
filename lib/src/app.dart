import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/screens/dashboard_screen.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';

class FuelConsumptionApp extends StatelessWidget {
  const FuelConsumptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '油耗',
        theme: ThemeData(
          useMaterial3: true,
          fontFamilyFallback: const ['Microsoft YaHei', 'SimSun'],
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.sky,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.scaffold,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.text,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              side: BorderSide(color: AppColors.border),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
