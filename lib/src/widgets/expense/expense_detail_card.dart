import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class ExpenseDetailCard extends StatelessWidget {
  const ExpenseDetailCard({required this.items, super.key});

  final List<ExpenseItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '费用明细'),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 86,
                  child: Center(child: Text('暂无费用明细')),
                ),
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _ExpenseDetailTile(item: items[index]),
                if (index != items.length - 1) const Divider(height: 1),
              ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseDetailTile extends StatelessWidget {
  const _ExpenseDetailTile({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      EnergyExpenseItem(:final record) => _EnergyExpenseTile(record: record),
      MaintenanceExpenseItem(:final record) => _MaintenanceExpenseTile(
        record: record,
      ),
    };
  }
}

class _EnergyExpenseTile extends StatelessWidget {
  const _EnergyExpenseTile({required this.record});

  final EnergyRecord record;

  @override
  Widget build(BuildContext context) {
    return _ExpenseTileLayout(
      icon: energyIcon(record.energyType),
      iconColor: energyColor(record.energyType),
      title: record.energyType.label,
      subtitle:
          '${shortDate(record.date)} ${shortTime(record.date)} · ${recordSubtitle(record)}',
      amount: record.totalCost,
    );
  }
}

class _MaintenanceExpenseTile extends StatelessWidget {
  const _MaintenanceExpenseTile({required this.record});

  final MaintenanceRecord record;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${shortDate(record.date)} ${shortTime(record.date)}',
      if (record.shop.isNotEmpty) record.shop,
      if (record.note.isNotEmpty) record.note,
    ].join(' · ');
    return _ExpenseTileLayout(
      icon: _maintenanceIcon(record.category),
      iconColor: AppColors.maintenance,
      title: '维修保养 · ${record.category.label}',
      subtitle: subtitle,
      amount: record.cost,
    );
  }
}

class _ExpenseTileLayout extends StatelessWidget {
  const _ExpenseTileLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.13),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${amount.toStringAsFixed(2)} 元',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

IconData _maintenanceIcon(MaintenanceCategory category) {
  return switch (category) {
    MaintenanceCategory.regular => Icons.build_circle_outlined,
    MaintenanceCategory.oil => Icons.oil_barrel_outlined,
    MaintenanceCategory.tire => Icons.album_outlined,
    MaintenanceCategory.repair => Icons.handyman_outlined,
    MaintenanceCategory.wash => Icons.local_car_wash_outlined,
    MaintenanceCategory.insurance => Icons.verified_user_outlined,
    MaintenanceCategory.other => Icons.more_horiz,
  };
}
