import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';

class MineTileIcon extends StatelessWidget {
  const MineTileIcon({required this.icon, super.key});

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
