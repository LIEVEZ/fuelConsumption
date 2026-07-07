import 'package:flutter/foundation.dart';
import 'package:fuel_consumption/src/presentation/dashboard_navigation.dart';

class DashboardController extends ChangeNotifier {
  DashboardPage _selectedPage = DashboardPage.consumption;
  String? _selectedVehicleId;

  DashboardPage get selectedPage => _selectedPage;
  String? get selectedVehicleId => _selectedVehicleId;

  DashboardTab? get selectedTab => switch (_selectedPage) {
    DashboardPage.consumption => DashboardTab.consumption,
    DashboardPage.expense => DashboardTab.expense,
    DashboardPage.energy => DashboardTab.energy,
    DashboardPage.maintenance => null,
    DashboardPage.mine => DashboardTab.mine,
  };

  String get title => switch (_selectedPage) {
    DashboardPage.consumption => '油耗',
    DashboardPage.expense => '费用',
    DashboardPage.energy => '补能',
    DashboardPage.maintenance => '保养',
    DashboardPage.mine => '我的中心',
  };

  void selectTab(DashboardTab tab) {
    _setPage(tab.page);
  }

  void selectCreateAction(CreateRecordAction action) {
    _setPage(switch (action) {
      CreateRecordAction.energy => DashboardPage.energy,
      CreateRecordAction.maintenance => DashboardPage.maintenance,
    });
  }

  void selectVehicle(String id) {
    _selectedVehicleId = id;
    _selectedPage = DashboardPage.consumption;
    notifyListeners();
  }

  void clearSelectedVehicleIfDeleted(String id) {
    if (_selectedVehicleId != id) return;
    _selectedVehicleId = null;
    notifyListeners();
  }

  void goHome() {
    _setPage(DashboardPage.consumption);
  }

  void goToExpense() {
    _setPage(DashboardPage.expense);
  }

  void _setPage(DashboardPage page) {
    if (_selectedPage == page) return;
    _selectedPage = page;
    notifyListeners();
  }
}
