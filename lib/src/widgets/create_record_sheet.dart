import 'package:flutter/material.dart';

enum CreateRecordAction { refuel, maintenance }

class CreateRecordSheet extends StatelessWidget {
  const CreateRecordSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.local_gas_station)),
              title: const Text('加油'),
              subtitle: const Text('记录本次加油、费用和优惠'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(CreateRecordAction.refuel),
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
