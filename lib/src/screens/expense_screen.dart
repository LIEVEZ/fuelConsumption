import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/widgets/expense/annual_expense_card.dart';
import 'package:fuel_consumption/src/widgets/expense/expense_composition_card.dart';
import 'package:fuel_consumption/src/widgets/expense/expense_detail_card.dart';
import 'package:fuel_consumption/src/widgets/expense/expense_hero_card.dart';
import 'package:fuel_consumption/src/widgets/expense/expense_metric_card.dart';
import 'package:fuel_consumption/src/widgets/expense/income_empty_card.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({
    required this.vehicle,
    required this.records,
    required this.maintenanceRecords,
    super.key,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;

  @override
  Widget build(BuildContext context) {
    final summary = ExpenseSummary.from(
      vehicle: vehicle,
      records: records,
      maintenanceRecords: maintenanceRecords,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      children: [
        ExpenseHeroCard(summary: summary),
        const SizedBox(height: 14),
        ExpenseMetricCard(summary: summary),
        const SizedBox(height: 14),
        AnnualExpenseCard(years: summary.annualExpenses),
        const SizedBox(height: 14),
        ExpenseCompositionCard(summary: summary),
        const SizedBox(height: 14),
        const IncomeEmptyCard(),
        const SizedBox(height: 14),
        ExpenseDetailCard(items: summary.items),
      ],
    );
  }
}
