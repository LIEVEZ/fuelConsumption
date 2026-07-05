import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/data/repository_provider.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/consumption_screen.dart';
import 'package:fuel_consumption/src/screens/dashboard_data_builder.dart';
import 'package:fuel_consumption/src/screens/expense_screen.dart';
import 'package:fuel_consumption/src/screens/maintenance_screen.dart';
import 'package:fuel_consumption/src/screens/mine_screen.dart';
import 'package:fuel_consumption/src/screens/refuel_screen.dart';
import 'package:fuel_consumption/src/widgets/app_bottom_nav.dart';
import 'package:fuel_consumption/src/widgets/create_record_sheet.dart';
import 'package:fuel_consumption/src/widgets/dialogs/import_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/text_payload_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/vehicle_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  _DashboardPage _selectedPage = _DashboardPage.consumption;
  String? _selectedVehicleId;

  DashboardTab? get _selectedTab => switch (_selectedPage) {
    _DashboardPage.consumption => DashboardTab.consumption,
    _DashboardPage.expense => DashboardTab.expense,
    _DashboardPage.refuel => DashboardTab.refuel,
    _DashboardPage.maintenance => null,
    _DashboardPage.mine => DashboardTab.mine,
  };

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(repositoryProvider);
    return DashboardDataBuilder(
      repository: repository,
      selectedVehicleId: _selectedVehicleId,
      builder: (context, data) => _buildScaffold(
        context: context,
        vehicles: data.vehicles,
        selectedVehicle: data.selectedVehicle,
        child: _tabBody(data, repository),
      ),
      emptyBuilder: (context, vehicles) => _buildScaffold(
        context: context,
        vehicles: vehicles,
        selectedVehicle: null,
        child: _emptyPageForCurrentTab(),
      ),
      loadingBuilder: (context, vehicles, selectedVehicle) => _buildScaffold(
        context: context,
        vehicles: vehicles,
        selectedVehicle: selectedVehicle,
        child: const DashboardLoadingState(),
      ),
      errorBuilder: (context, vehicles, selectedVehicle, error) =>
          _buildScaffold(
            context: context,
            vehicles: vehicles,
            selectedVehicle: selectedVehicle,
            child: DashboardErrorState(error: error),
          ),
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required List<Vehicle> vehicles,
    required Vehicle? selectedVehicle,
    required Widget child,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForTab()),
        leading: _selectedTab == DashboardTab.mine
            ? IconButton(
                tooltip: '返回油耗',
                icon: const Icon(Icons.home_outlined),
                onPressed: () =>
                    setState(() => _selectedPage = _DashboardPage.consumption),
              )
            : null,
      ),
      body: child,
      bottomNavigationBar: AppBottomNav(
        selectedTab: _selectedTab,
        onSelected: (tab) => setState(() => _selectedPage = tab.page),
        onCreateTap: _showCreateMenu,
      ),
    );
  }

  Widget _tabBody(DashboardData data, AppRepository repository) {
    return switch (_selectedPage) {
      _DashboardPage.consumption => ConsumptionScreen(
        vehicle: data.selectedVehicle,
        records: data.records,
        chronologicalRecords: data.chronologicalRecords,
        maintenanceRecords: data.maintenanceRecords,
        stats: data.stats,
      ),
      _DashboardPage.expense => ExpenseScreen(
        vehicle: data.selectedVehicle,
        records: data.records,
        maintenanceRecords: data.maintenanceRecords,
      ),
      _DashboardPage.refuel => RefuelScreen(
        vehicle: data.selectedVehicle,
        records: data.chronologicalRecords,
        onSave: repository.saveRecord,
        onSaved: () =>
            setState(() => _selectedPage = _DashboardPage.consumption),
      ),
      _DashboardPage.maintenance => MaintenanceScreen(
        vehicle: data.selectedVehicle,
        onSave: repository.saveMaintenanceRecord,
        onSaved: () => setState(() => _selectedPage = _DashboardPage.expense),
      ),
      _DashboardPage.mine => MineScreen(
        vehicles: data.vehicles,
        selectedVehicleId: data.selectedVehicle.id,
        onVehicleSelected: (id) {
          setState(() {
            _selectedVehicleId = id;
            _selectedPage = _DashboardPage.consumption;
          });
        },
        onAddVehicle: _showVehicleDialog,
        onDeleteVehicle: _confirmDeleteVehicle,
        onExport: _exportJson,
        onImport: _importJson,
      ),
    };
  }

  Widget _emptyPageForCurrentTab() {
    if (_selectedPage == _DashboardPage.mine) {
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

  String _titleForTab() {
    return switch (_selectedPage) {
      _DashboardPage.consumption => '油耗',
      _DashboardPage.expense => '费用',
      _DashboardPage.refuel => '优惠加油',
      _DashboardPage.maintenance => '保养',
      _DashboardPage.mine => '我的中心',
    };
  }

  Future<void> _showCreateMenu() async {
    final action = await showModalBottomSheet<CreateRecordAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => const CreateRecordSheet(),
    );
    if (!mounted || action == null) return;
    setState(() {
      _selectedPage = switch (action) {
        CreateRecordAction.refuel => _DashboardPage.refuel,
        CreateRecordAction.maintenance => _DashboardPage.maintenance,
      };
    });
  }

  Future<void> _showVehicleDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          VehicleDialog(repository: ref.read(repositoryProvider)),
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
    if (_selectedVehicleId == vehicle.id) {
      setState(() => _selectedVehicleId = null);
    }
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
      builder: (context) =>
          ImportDialog(repository: ref.read(repositoryProvider)),
    );
    if (!mounted || result == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) =>
          TextPayloadDialog(title: '导入前自动备份', text: result.preImportBackupJson),
    );
  }
}

enum _DashboardPage { consumption, expense, refuel, maintenance, mine }

extension on DashboardTab {
  _DashboardPage get page => switch (this) {
    DashboardTab.consumption => _DashboardPage.consumption,
    DashboardTab.expense => _DashboardPage.expense,
    DashboardTab.refuel => _DashboardPage.refuel,
    DashboardTab.mine => _DashboardPage.mine,
  };
}
