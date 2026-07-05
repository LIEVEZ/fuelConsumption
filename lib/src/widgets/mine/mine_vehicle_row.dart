import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_tile_icon.dart';

class MineVehicleRow extends StatelessWidget {
  const MineVehicleRow({
    required this.vehicle,
    required this.selected,
    required this.onTap,
    required this.onSelect,
    required this.onDelete,
    super.key,
  });

  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            MineTileIcon(icon: vehicleIcon(vehicle.type)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      vehicle.type.label,
                      if (vehicle.model.isNotEmpty) vehicle.model,
                      '${vehicle.initialOdometerKm.toStringAsFixed(0)} km 起记',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSubtle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            PopupMenuButton<MineVehicleAction>(
              tooltip: '车辆操作',
              onSelected: (action) {
                switch (action) {
                  case MineVehicleAction.select:
                    onSelect();
                  case MineVehicleAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                if (!selected)
                  const PopupMenuItem(
                    value: MineVehicleAction.select,
                    child: Text('设为当前车辆'),
                  ),
                const PopupMenuItem(
                  value: MineVehicleAction.delete,
                  child: Text('删除车辆'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum MineVehicleAction { select, delete }
