import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_info_sheet.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_menu_tile.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_section_card.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_vehicle_row.dart';

void main() {
  testWidgets('menu tile renders subtitle and handles tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MineMenuTile(
            icon: Icons.upload_file_outlined,
            title: '本地备份导出',
            subtitle: '生成 JSON 备份',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('本地备份导出'), findsOneWidget);
    expect(find.text('生成 JSON 备份'), findsOneWidget);

    await tester.tap(find.text('本地备份导出'));

    expect(tapped, isTrue);
  });

  testWidgets('section card keeps children order without trailing divider', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MineSectionCard(
            title: '车辆与数据',
            children: [Text('第一项'), Text('第二项')],
          ),
        ),
      ),
    );

    expect(find.text('车辆与数据'), findsOneWidget);
    expect(find.text('第一项'), findsOneWidget);
    expect(find.text('第二项'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('vehicle row exposes selected state and delete action', (
    tester,
  ) async {
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MineVehicleRow(
            vehicle: const Vehicle(
              id: 'vehicle-1',
              name: '家用车',
              type: VehicleType.fuel,
              initialOdometerKm: 12000,
              model: 'SUV',
            ),
            selected: true,
            onTap: () {},
            onSelect: () {},
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('家用车'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.byTooltip('车辆操作'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除车辆'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });

  testWidgets('info sheet displays title and bullet lines', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MineInfoSheet(
            title: '使用帮助',
            icon: Icons.help_outline,
            lines: ['点击底部“记一笔”可以选择记录加油或保养。', '本地备份导出会生成 JSON。'],
          ),
        ),
      ),
    );

    expect(find.text('使用帮助'), findsOneWidget);
    expect(find.text('点击底部“记一笔”可以选择记录加油或保养。'), findsOneWidget);
    expect(find.text('本地备份导出会生成 JSON。'), findsOneWidget);
  });
}
