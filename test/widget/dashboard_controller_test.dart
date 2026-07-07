import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_consumption/src/presentation/dashboard_navigation.dart';
import 'package:fuel_consumption/src/screens/dashboard_controller.dart';

void main() {
  test('maps tabs and create actions to dashboard pages', () {
    final controller = DashboardController();
    addTearDown(controller.dispose);

    expect(controller.selectedPage, DashboardPage.consumption);
    expect(controller.selectedTab, DashboardTab.consumption);
    expect(controller.title, '油耗');

    controller.selectTab(DashboardTab.expense);
    expect(controller.selectedPage, DashboardPage.expense);
    expect(controller.title, '费用');

    controller.selectTab(DashboardTab.energy);
    expect(controller.selectedPage, DashboardPage.energy);
    expect(controller.selectedTab, DashboardTab.energy);
    expect(controller.title, '补能');

    controller.selectCreateAction(CreateRecordAction.maintenance);
    expect(controller.selectedPage, DashboardPage.maintenance);
    expect(controller.selectedTab, isNull);
    expect(controller.title, '保养');

    controller.selectCreateAction(CreateRecordAction.energy);
    expect(controller.selectedPage, DashboardPage.energy);
    expect(controller.selectedTab, DashboardTab.energy);

    controller.goHome();
    expect(controller.selectedPage, DashboardPage.consumption);
  });

  test('selects a vehicle and clears it after deletion', () {
    final controller = DashboardController();
    addTearDown(controller.dispose);

    controller.selectTab(DashboardTab.mine);
    controller.selectVehicle('vehicle-1');

    expect(controller.selectedVehicleId, 'vehicle-1');
    expect(controller.selectedPage, DashboardPage.consumption);

    controller.clearSelectedVehicleIfDeleted('vehicle-2');
    expect(controller.selectedVehicleId, 'vehicle-1');

    controller.clearSelectedVehicleIfDeleted('vehicle-1');
    expect(controller.selectedVehicleId, isNull);
  });
}
