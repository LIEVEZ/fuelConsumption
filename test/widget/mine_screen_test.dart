import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/mine_screen.dart';

void main() {
  testWidgets(
    'shows local vehicle and data center without old account labels',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MineScreen(
              vehicles: const [
                Vehicle(
                  id: 'vehicle-1',
                  name: '家用车',
                  type: VehicleType.fuel,
                  initialOdometerKm: 12000,
                  model: 'SUV',
                  isDefault: true,
                ),
              ],
              selectedVehicleId: 'vehicle-1',
              onVehicleSelected: (_) {},
              onAddVehicle: () {},
              onDeleteVehicle: (_) {},
              onExport: () {},
              onImport: () {},
            ),
          ),
        ),
      );

      expect(find.text('车辆与数据'), findsOneWidget);
      expect(find.text('车辆管理'), findsOneWidget);
      expect(find.text('家用车'), findsOneWidget);
      expect(find.text('本地备份导出'), findsOneWidget);
      expect(find.text('LIEVE'), findsNothing);
      expect(find.text('ID'), findsNothing);
      expect(find.text('退出登录'), findsNothing);
    },
  );
}
