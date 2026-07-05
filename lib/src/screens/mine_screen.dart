import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_feedback_sheet.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_info_sheet.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_menu_tile.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_section_card.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_vehicle_row.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_version_tile.dart';

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        MineSectionCard(
          title: '车辆与数据',
          children: [
            MineMenuTile(
              icon: Icons.directions_car_outlined,
              title: '车辆管理',
              subtitle: vehicles.isEmpty ? '添加第一辆车' : '${vehicles.length} 辆车',
              onTap: onAddVehicle,
            ),
            if (vehicles.isNotEmpty)
              for (final vehicle in vehicles)
                MineVehicleRow(
                  vehicle: vehicle,
                  selected: vehicle.id == selectedVehicleId,
                  onTap: () => onVehicleSelected(vehicle.id),
                  onSelect: () => onVehicleSelected(vehicle.id),
                  onDelete: () => onDeleteVehicle(vehicle),
                ),
            MineMenuTile(
              icon: Icons.upload_file_outlined,
              title: '本地备份导出',
              subtitle: '生成 JSON 备份',
              onTap: onExport,
            ),
            MineMenuTile(
              icon: Icons.download_for_offline_outlined,
              title: '本地备份导入',
              subtitle: '从 JSON 恢复数据',
              onTap: onImport,
            ),
          ],
        ),
        const SizedBox(height: 16),
        MineSectionCard(
          title: '支持',
          children: [
            MineMenuTile(
              icon: Icons.help_outline,
              title: '使用帮助',
              subtitle: '记录加油、保养和备份说明',
              onTap: () => _showInfoSheet(
                context,
                title: '使用帮助',
                icon: Icons.help_outline,
                lines: const [
                  '点击底部“记一笔”可以选择记录加油或保养。',
                  '加油页任意输入两项金额/数量，系统会自动计算另一项。',
                  '费用页会汇总油费、保养费用、支出/公里和年度统计。',
                  '本地备份导出会生成 JSON，可用于换机或手动留档。',
                ],
              ),
            ),
            MineMenuTile(
              icon: Icons.chat_bubble_outline,
              title: '投诉与反馈',
              subtitle: '记录问题或改进建议',
              onTap: () => _showFeedbackSheet(context),
            ),
            MineMenuTile(
              icon: Icons.privacy_tip_outlined,
              title: '数据与隐私',
              subtitle: '数据保存在本机，备份由你手动导出',
              onTap: () => _showInfoSheet(
                context,
                title: '数据与隐私',
                icon: Icons.privacy_tip_outlined,
                lines: const [
                  '车辆、加油、保养和费用记录保存在本机数据库。',
                  '应用不会把数据自动上传到云端。',
                  '本地备份导出的是 JSON 文本，请自行保存到可信位置。',
                  '导入备份会按当前导入逻辑恢复本地数据。',
                ],
              ),
            ),
            const MineVersionTile(),
          ],
        ),
      ],
    );
  }

  Future<void> _showInfoSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> lines,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) =>
          MineInfoSheet(title: title, icon: icon, lines: lines),
    );
  }

  Future<void> _showFeedbackSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const MineFeedbackSheet(),
    );
  }
}
