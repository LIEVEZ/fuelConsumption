import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';

class MineScreen extends StatelessWidget {
  const MineScreen({
    required this.vehicles,
    required this.selectedVehicleId,
    required this.onVehicleSelected,
    required this.onAddVehicle,
    required this.onDeleteVehicle,
    required this.onExport,
    required this.onImport,
    super.key,
  });

  final List<Vehicle> vehicles;
  final String? selectedVehicleId;
  final ValueChanged<String> onVehicleSelected;
  final VoidCallback onAddVehicle;
  final ValueChanged<Vehicle> onDeleteVehicle;
  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = _selectedVehicle();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ProfileHeader(
          vehicleCount: vehicles.length,
          selectedVehicle: selectedVehicle,
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '车辆与数据',
          children: [
            _MenuTile(
              icon: Icons.directions_car_outlined,
              title: '车辆管理',
              subtitle: vehicles.isEmpty ? '添加第一辆车' : '${vehicles.length} 辆车',
              onTap: onAddVehicle,
            ),
            if (vehicles.isNotEmpty)
              for (final vehicle in vehicles)
                _VehicleRow(
                  vehicle: vehicle,
                  selected: vehicle.id == selectedVehicleId,
                  onTap: () => onVehicleSelected(vehicle.id),
                  onDelete: () => onDeleteVehicle(vehicle),
                ),
            _MenuTile(
              icon: Icons.upload_file_outlined,
              title: '本地备份导出',
              subtitle: '生成 JSON 备份',
              onTap: onExport,
            ),
            _MenuTile(
              icon: Icons.download_for_offline_outlined,
              title: '本地备份导入',
              subtitle: '从 JSON 恢复数据',
              onTap: onImport,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: '支持',
          children: [
            _MenuTile(
              icon: Icons.help_outline,
              title: '使用帮助',
              subtitle: '记录加油、保养和备份说明',
              onTap: () => _showComingSoon(context),
            ),
            _MenuTile(
              icon: Icons.chat_bubble_outline,
              title: '投诉与反馈',
              subtitle: '记录问题或改进建议',
              onTap: () => _showComingSoon(context),
            ),
            const _VersionTile(),
          ],
        ),
      ],
    );
  }

  Vehicle? _selectedVehicle() {
    if (vehicles.isEmpty) return null;
    return vehicles.firstWhere(
      (vehicle) => vehicle.id == selectedVehicleId,
      orElse: () => vehicles.firstWhere(
        (vehicle) => vehicle.isDefault,
        orElse: () => vehicles.first,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('功能整理中')));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.vehicleCount,
    required this.selectedVehicle,
  });

  final int vehicleCount;
  final Vehicle? selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final subtitle = selectedVehicle == null
        ? '添加车辆后开始记录费用'
        : '当前车辆：${selectedVehicle!.name}';
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              selectedVehicle == null
                  ? Icons.garage_outlined
                  : vehicleIcon(selectedVehicle!.type),
              color: AppColors.skyDark,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '本地用车档案',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderPill(text: '$vehicleCount 辆车'),
                    const _HeaderPill(text: '本机保存'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.skyPill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.skyDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const _SectionDivider(),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _TileIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSubtle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({
    required this.vehicle,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;
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
            _TileIcon(icon: vehicleIcon(vehicle.type)),
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
            PopupMenuButton<_VehicleAction>(
              tooltip: '车辆操作',
              onSelected: (action) {
                switch (action) {
                  case _VehicleAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _VehicleAction.delete,
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

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.skyPill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.skyDark, size: 22),
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _TileIcon(icon: Icons.info_outline),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '版本',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '1.0.0',
            style: TextStyle(
              color: AppColors.textSubtle,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border);
  }
}

enum _VehicleAction { delete }
