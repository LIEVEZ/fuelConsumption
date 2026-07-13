import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/application/dashboard_commands.dart';
import 'package:fuel_consumption/src/application/dashboard_query.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/presentation/app_providers.dart';
import 'package:fuel_consumption/src/presentation/dashboard_navigation.dart';
import 'package:fuel_consumption/src/screens/dashboard_controller.dart';
import 'package:fuel_consumption/src/screens/dashboard_dialogs.dart';
import 'package:fuel_consumption/src/screens/consumption_screen.dart';
import 'package:fuel_consumption/src/screens/energy_record_screen.dart';
import 'package:fuel_consumption/src/screens/expense_screen.dart';
import 'package:fuel_consumption/src/screens/maintenance_screen.dart';
import 'package:fuel_consumption/src/screens/mine_screen.dart';
import 'package:fuel_consumption/src/widgets/app_bottom_nav.dart';
import 'package:fuel_consumption/src/widgets/dashboard/dashboard_states.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController()..addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final commands = ref.watch(dashboardCommandProvider);
    final dashboardState = ref.watch(
      dashboardQueryProvider(_controller.selectedVehicleId),
    );
    return switch (dashboardState.status) {
      DashboardLoadStatus.ready => _buildScaffold(
        context: context,
        vehicles: dashboardState.vehicles,
        selectedVehicle: dashboardState.selectedVehicle,
        child: _tabBody(dashboardState.data!, commands),
      ),
      DashboardLoadStatus.empty => _buildScaffold(
        context: context,
        vehicles: dashboardState.vehicles,
        selectedVehicle: null,
        child: _emptyPageForCurrentTab(),
      ),
      DashboardLoadStatus.loading => _buildScaffold(
        context: context,
        vehicles: dashboardState.vehicles,
        selectedVehicle: dashboardState.selectedVehicle,
        child: const DashboardLoadingState(),
      ),
      DashboardLoadStatus.error => _buildScaffold(
        context: context,
        vehicles: dashboardState.vehicles,
        selectedVehicle: dashboardState.selectedVehicle,
        child: DashboardErrorState(error: dashboardState.error!),
      ),
    };
  }

  Widget _buildScaffold({
    required BuildContext context,
    required List<Vehicle> vehicles,
    required Vehicle? selectedVehicle,
    required Widget child,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle(selectedVehicle)),
        leading: _controller.selectedTab == DashboardTab.mine
            ? IconButton(
                tooltip: '返回油耗',
                icon: const Icon(Icons.home_outlined),
                onPressed: _controller.goHome,
              )
            : null,
      ),
      body: child,
      bottomNavigationBar: AppBottomNav(
        selectedTab: _controller.selectedTab,
        onSelected: _controller.selectTab,
        onCreateTap: () => _showCreateMenu(selectedVehicle?.type),
      ),
    );
  }

  Widget _tabBody(DashboardData data, DashboardCommandService commands) {
    return switch (_controller.selectedPage) {
      DashboardPage.consumption => ConsumptionScreen(
        vehicle: data.selectedVehicle,
        records: data.records,
        chronologicalRecords: data.chronologicalRecords,
        maintenanceRecords: data.maintenanceRecords,
        stats: data.stats,
      ),
      DashboardPage.expense => ExpenseScreen(
        vehicle: data.selectedVehicle,
        records: data.records,
        maintenanceRecords: data.maintenanceRecords,
      ),
      DashboardPage.energy => EnergyRecordScreen(
        vehicle: data.selectedVehicle,
        records: data.chronologicalRecords,
        onSaveRefuel: commands.saveRefuelRecord,
        onSaveCharge: commands.saveChargeRecord,
        onSaveHybrid: commands.saveHybridRecord,
        onSaved: _controller.goHome,
      ),
      DashboardPage.maintenance => MaintenanceScreen(
        key: ValueKey('maintenance-${data.selectedVehicle.id}'),
        vehicle: data.selectedVehicle,
        onSave: commands.saveMaintenanceRecord,
        onSaved: _controller.goToExpense,
      ),
      DashboardPage.mine => MineScreen(
        vehicles: data.vehicles,
        selectedVehicleId: data.selectedVehicle.id,
        onVehicleSelected: _controller.selectVehicle,
        onAddVehicle: _showVehicleDialog,
        onDeleteVehicle: _confirmDeleteVehicle,
        onExport: _exportJson,
        onImport: _importJson,
      ),
    };
  }

  String _pageTitle(Vehicle? selectedVehicle) {
    if (_controller.selectedPage != DashboardPage.energy) {
      return _controller.title;
    }
    return switch (selectedVehicle?.type) {
      VehicleType.electric => '充电',
      VehicleType.hybrid => '油电补能',
      VehicleType.fuel || VehicleType.motorcycle => '优惠加油',
      null => '补能',
    };
  }

  Widget _emptyPageForCurrentTab() {
    if (_controller.selectedPage == DashboardPage.mine) {
      return MineScreen(
        vehicles: const [],
        selectedVehicleId: null,
        onVehicleSelected: (_) {},
        onAddVehicle: _showVehicleDialog,
        onDeleteVehicle: _confirmDeleteVehicle,
        onExport: _exportJson,
        onImport: _importJson,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_gas_station,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('还没有车辆', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('先建立车辆档案，再开始记录补能和费用。', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _showVehicleDialog,
              icon: const Icon(Icons.add_road),
              label: const Text('添加第一辆车'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateMenu(VehicleType? vehicleType) async {
    final action = await showDashboardCreateMenu(
      context: context,
      vehicleType: vehicleType,
    );
    if (!mounted || action == null) return;
    _controller.selectCreateAction(action);
  }

  Future<void> _showVehicleDialog() async {
    final commands = ref.read(dashboardCommandProvider);
    await showDashboardVehicleDialog(
      context: context,
      onSave: commands.createVehicle,
    );
  }

  Future<void> _confirmDeleteVehicle(Vehicle vehicle) async {
    final confirmed = await confirmDashboardVehicleDelete(
      context: context,
      vehicle: vehicle,
    );
    if (!mounted || !confirmed) return;
    await ref.read(dashboardCommandProvider).deleteVehicle(vehicle.id);
    if (!mounted) return;
    _controller.clearSelectedVehicleIfDeleted(vehicle.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已删除 ${vehicle.name}')));
  }

  Future<void> _exportJson() async {
    final json = await ref.read(dashboardCommandProvider).exportBackupJson();
    if (!mounted) return;
    await showDashboardTextPayload(
      context: context,
      title: 'JSON 备份',
      text: json,
    );
  }

  Future<void> _importJson() async {
    final result = await showDashboardImportDialog(
      context: context,
      actions: ref.read(dashboardCommandProvider).importActions,
    );
    if (!mounted || result == null) return;
    await showDashboardTextPayload(
      context: context,
      title: '导入前自动备份',
      text: result.preImportBackupJson,
    );
  }
}
