import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';

enum DashboardTab { consumption, records, refuel, maintenance, mine }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.selectedTab,
    required this.onSelected,
    required this.onCreateTap,
    super.key,
  });

  final DashboardTab selectedTab;
  final ValueChanged<DashboardTab> onSelected;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          height: 82,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.water_drop_outlined,
                selectedIcon: Icons.water_drop,
                label: '油耗',
                selected: selectedTab == DashboardTab.consumption,
                onTap: () => onSelected(DashboardTab.consumption),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet,
                label: '费用',
                selected: selectedTab == DashboardTab.records,
                onTap: () => onSelected(DashboardTab.records),
              ),
              _CenterAction(onTap: onCreateTap),
              _NavItem(
                icon: Icons.local_gas_station_outlined,
                selectedIcon: Icons.local_gas_station,
                label: '优惠加油',
                selected: selectedTab == DashboardTab.refuel,
                onTap: () => onSelected(DashboardTab.refuel),
              ),
              _NavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: '我的',
                selected: selectedTab == DashboardTab.mine,
                onTap: () => onSelected(DashboardTab.mine),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 66,
        height: 70,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.sky,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sky.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 3),
            const Text(
              '记一笔',
              maxLines: 1,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.sky : AppColors.text;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
