import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_tile_icon.dart';

class MineVersionTile extends StatelessWidget {
  const MineVersionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          MineTileIcon(icon: Icons.info_outline),
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
