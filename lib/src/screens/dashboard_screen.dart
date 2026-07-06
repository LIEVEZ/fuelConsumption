import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/application/backup_import_service.dart';
import 'package:fuel_consumption/src/application/dashboard_query.dart';
import 'package:fuel_consumption/src/application/vehicle_commands.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/data/repository_provider.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/dashboard_controller.dart';
import 'package:fuel_consumption/src/screens/consumption_screen.dart';
import 'package:fuel_consumption/src/screens/expense_screen.dart';
import 'package:fuel_consumption/src/screens/maintenance_screen.dart';
import 'package:fuel_consumption/src/screens/mine_screen.dart';
import 'package:fuel_consumption/src/screens/refuel_screen.dart';
import 'package:fuel_consumption/src/widgets/app_bottom_nav.dart';
import 'package:fuel_consumption/src/widgets/create_record_sheet.dart';
import 'package:fuel_consumption/src/widgets/dashboard/dashboard_states.dart';
import 'package:fuel_consumption/src/widgets/dialogs/import_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/text_payload_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/vehicle_dialog.dart';

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
    final repository = ref.watch(repositoryProvider);
    final dashboardState = ref.watch(
      dashboardQueryProvider(_controller.selectedVehicleId),
    );
    return switch (dashboardState.status) {
      DashboardLoadStatus.ready => _buildScaffold(
        context: context,
        vehicles: dashboardState.vehicles,
        selectedVehicle: dashboardState.selectedVehicle,
        child: _tabBody(dashboardState.data!, repository),
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
        title: Text(_controller.title),
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
        onCreateTap: _showCreateMenu,
      ),
    );
  }

  Widget _tabBody(DashboardData data, AppRepository repository) {
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
      DashboardPage.refuel => RefuelScreen(
        vehicle: data.selectedVehicle,
        records: data.chronologicalRecords,
        onSave: repository.saveRecord,
        onSaved: _controller.goHome,
      ),
      DashboardPage.maintenance => MaintenanceScreen(
        vehicle: data.selectedVehicle,
        onSave: repository.saveMaintenanceRecord,
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

  Future<void> _showCreateMenu() async {
    final action = await showModalBottomSheet<CreateRecordAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => const CreateRecordSheet(),
    );
    if (!mounted || action == null) return;
    _controller.selectCreateAction(action);
  }

  Future<void> _showVehicleDialog() async {
    final repository = ref.read(repositoryProvider);
    final vehicleCommands = VehicleCommandService(repository: repository);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          VehicleDialog(onSave: vehicleCommands.createVehicle),
    );
  }

  Future<void> _confirmDeleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除车辆'),
        content: Text('确定删除「${vehicle.name}」吗？该车辆的补能记录也会一起删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await ref.read(repositoryProvider).deleteVehicle(vehicle.id);
    if (!mounted) return;
    _controller.clearSelectedVehicleIfDeleted(vehicle.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已删除 ${vehicle.name}')));
  }

  Future<void> _exportJson() async {
    final backup = await ref.read(repositoryProvider).exportBackup();
    final json = BackupCodec().encode(backup);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => TextPayloadDialog(title: 'JSON 备份', text: json),
    );
  }

  Future<void> _importJson() async {
    final result = await showDialog<ImportBackupResult>(
      context: context,
      builder: (context) => ImportDialog(
        actions: BackupImportService(repository: ref.read(repositoryProvider)),
      ),
    );
    if (!mounted || result == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) =>
          TextPayloadDialog(title: '导入前自动备份', text: result.preImportBackupJson),
    );
  }
}
