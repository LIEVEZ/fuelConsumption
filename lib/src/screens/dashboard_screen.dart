import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/statistics.dart';
import 'package:fuel_consumption/src/screens/consumption_screen.dart';
import 'package:fuel_consumption/src/screens/expense_screen.dart';
import 'package:fuel_consumption/src/screens/maintenance_screen.dart';
import 'package:fuel_consumption/src/screens/mine_screen.dart';
import 'package:fuel_consumption/src/screens/refuel_screen.dart';
import 'package:fuel_consumption/src/widgets/app_bottom_nav.dart';
import 'package:fuel_consumption/src/widgets/dialogs/import_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/text_payload_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/vehicle_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.repository, super.key});

  final AppRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardTab _selectedTab = DashboardTab.consumption;
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Vehicle>>(
      stream: widget.repository.watchVehicles(),
      builder: (context, vehicleSnapshot) {
        final vehicles = vehicleSnapshot.data ?? const <Vehicle>[];
        final selectedVehicle = _resolveVehicle(vehicles);
        final selectedVehicleId = selectedVehicle?.id;

        if (selectedVehicleId == null) {
          return _buildScaffold(
            context: context,
            vehicles: vehicles,
            selectedVehicle: null,
            records: const [],
            child: _emptyPageForCurrentTab(),
          );
        }

        return StreamBuilder<List<EnergyRecord>>(
          stream: widget.repository.watchRecords(selectedVehicleId),
          builder: (context, recordSnapshot) {
            final records = recordSnapshot.data ?? const <EnergyRecord>[];
            final chronological = [...records]
              ..sort((a, b) => a.date.compareTo(b.date));
            final stats = EnergyStatisticsCalculator().build(
              selectedVehicle!,
              chronological,
            );

            return StreamBuilder<List<MaintenanceRecord>>(
              stream: widget.repository.watchMaintenanceRecords(
                selectedVehicleId,
              ),
              builder: (context, maintenanceSnapshot) {
                final maintenanceRecords =
                    maintenanceSnapshot.data ?? const <MaintenanceRecord>[];
                return _buildScaffold(
                  context: context,
                  vehicles: vehicles,
                  selectedVehicle: selectedVehicle,
                  records: records,
                  child: _tabBody(
                    vehicles,
                    selectedVehicle,
                    records,
                    chronological,
                    maintenanceRecords,
                    stats,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required List<Vehicle> vehicles,
    required Vehicle? selectedVehicle,
    required List<EnergyRecord> records,
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
                    setState(() => _selectedTab = DashboardTab.consumption),
              )
            : null,
      ),
      body: child,
      bottomNavigationBar: AppBottomNav(
        selectedTab: _selectedTab,
        onSelected: (tab) => setState(() => _selectedTab = tab),
        onCreateTap: _showCreateMenu,
      ),
    );
  }

  Widget _tabBody(
    List<Vehicle> vehicles,
    Vehicle vehicle,
    List<EnergyRecord> records,
    List<EnergyRecord> chronological,
    List<MaintenanceRecord> maintenanceRecords,
    StatisticsSnapshot stats,
  ) {
    return switch (_selectedTab) {
      DashboardTab.consumption => ConsumptionScreen(
        vehicle: vehicle,
        records: records,
        chronologicalRecords: chronological,
        maintenanceRecords: maintenanceRecords,
        stats: stats,
      ),
      DashboardTab.records => ExpenseScreen(
        vehicle: vehicle,
        records: records,
        maintenanceRecords: maintenanceRecords,
      ),
      DashboardTab.refuel => RefuelScreen(
        vehicle: vehicle,
        records: chronological,
        onSave: widget.repository.saveRecord,
        onSaved: () => setState(() => _selectedTab = DashboardTab.consumption),
      ),
      DashboardTab.maintenance => MaintenanceScreen(
        vehicle: vehicle,
        onSave: widget.repository.saveMaintenanceRecord,
        onSaved: () => setState(() => _selectedTab = DashboardTab.records),
      ),
      DashboardTab.mine => MineScreen(
        vehicles: vehicles,
        selectedVehicleId: vehicle.id,
        onVehicleSelected: (id) {
          setState(() {
            _selectedVehicleId = id;
            _selectedTab = DashboardTab.consumption;
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
    if (_selectedTab == DashboardTab.mine) {
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

  Vehicle? _resolveVehicle(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) return null;
    return vehicles.firstWhere(
      (vehicle) => vehicle.id == _selectedVehicleId,
      orElse: () => vehicles.firstWhere(
        (vehicle) => vehicle.isDefault,
        orElse: () => vehicles.first,
      ),
    );
  }

  String _titleForTab() {
    return switch (_selectedTab) {
      DashboardTab.consumption => '油耗',
      DashboardTab.records => '费用',
      DashboardTab.refuel => '优惠加油',
      DashboardTab.maintenance => '保养',
      DashboardTab.mine => '我的中心',
    };
  }

  Future<void> _showCreateMenu() async {
    final action = await showModalBottomSheet<_CreateAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.local_gas_station),
                ),
                title: const Text('加油'),
                subtitle: const Text('记录本次加油、费用和优惠'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pop(_CreateAction.refuel),
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.build)),
                title: const Text('保养'),
                subtitle: const Text('记录保养、维修等车辆费用'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).pop(_CreateAction.maintenance),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    setState(() {
      _selectedTab = switch (action) {
        _CreateAction.refuel => DashboardTab.refuel,
        _CreateAction.maintenance => DashboardTab.maintenance,
      };
    });
  }

  Future<void> _showVehicleDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => VehicleDialog(repository: widget.repository),
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
    await widget.repository.deleteVehicle(vehicle.id);
    if (!mounted) return;
    if (_selectedVehicleId == vehicle.id) {
      setState(() => _selectedVehicleId = null);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已删除 ${vehicle.name}')));
  }

  Future<void> _exportJson() async {
    final backup = await widget.repository.exportBackup();
    final json = BackupCodec().encode(backup);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => TextPayloadDialog(title: 'JSON 备份', text: json),
    );
  }

  Future<void> _importJson() async {
    await showDialog<void>(
      context: context,
      builder: (context) => ImportDialog(repository: widget.repository),
    );
  }
}

enum _CreateAction { refuel, maintenance }
