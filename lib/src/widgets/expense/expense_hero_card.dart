import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/expense_statistics.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';

class ExpenseHeroCard extends StatelessWidget {
  const ExpenseHeroCard({required this.summary, super.key});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    final companion = summary.hasCompanionDate
        ? '已相伴 ${summary.companionDays} 天'
        : '暂无用车记录';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -18,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.sky.withValues(alpha: 0.16),
                  child: Icon(
                    vehicleIcon(summary.vehicle.type),
                    color: AppColors.skyDark,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.vehicle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          summary.vehicle.type.label,
                          if (summary.vehicle.model.isNotEmpty)
                            summary.vehicle.model,
                          companion,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
