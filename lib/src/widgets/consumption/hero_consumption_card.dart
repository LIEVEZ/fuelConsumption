import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';

class HeroConsumptionCard extends StatelessWidget {
  const HeroConsumptionCard({
    required this.vehicle,
    required this.stats,
    super.key,
  });

  final Vehicle vehicle;
  final StatisticsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    final latest = parseLeadingNumber(stats.latestConsumptionLabel);
    final display = latest == null || latest == 0
        ? parseLeadingNumber(stats.averageConsumptionLabel)
        : latest;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -10,
            child: Container(
              width: 180,
              height: 116,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(72),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '最新油耗',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSubtle,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        vehicle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (display ?? 0).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _unitForVehicle(vehicle),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (var index = 0; index < 5; index++)
                      Icon(
                        Icons.star,
                        color: index < 3 ? AppColors.warning : AppColors.border,
                        size: 28,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _unitForVehicle(Vehicle vehicle) {
    return switch (vehicle.type) {
      VehicleType.electric => 'kWh/百公里',
      VehicleType.hybrid => '综合/百公里',
      VehicleType.fuel || VehicleType.motorcycle => '升/百公里',
    };
  }
}
