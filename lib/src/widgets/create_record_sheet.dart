import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/presentation/dashboard_navigation.dart';

class CreateRecordSheet extends StatelessWidget {
  const CreateRecordSheet({this.vehicleType, super.key});

  final VehicleType? vehicleType;

  @override
  Widget build(BuildContext context) {
    final energyOption = _energyOptionFor(vehicleType);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(child: Icon(energyOption.icon)),
              title: Text(energyOption.title),
              subtitle: Text(energyOption.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(CreateRecordAction.energy),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.build)),
              title: const Text('保养'),
              subtitle: const Text('记录保养、维修等车辆费用'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.of(context).pop(CreateRecordAction.maintenance),
            ),
          ],
        ),
      ),
    );
  }
}

_EnergyOption _energyOptionFor(VehicleType? type) {
  return switch (type) {
    VehicleType.electric => const _EnergyOption(
      title: '充电',
      subtitle: '记录本次充电电量和费用',
      icon: Icons.bolt,
    ),
    VehicleType.hybrid => const _EnergyOption(
      title: '油电补能',
      subtitle: '记录本次燃油和充电费用',
      icon: Icons.sync_alt,
    ),
    VehicleType.fuel || VehicleType.motorcycle || null => const _EnergyOption(
      title: '加油',
      subtitle: '记录本次加油、费用和优惠',
      icon: Icons.local_gas_station,
    ),
  };
}

class _EnergyOption {
  const _EnergyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
