import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuel_consumption/src/data/backup_codec.dart';
import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/statistics.dart';
import 'package:fuel_consumption/src/domain/validation.dart';
import 'package:uuid/uuid.dart';

class FuelConsumptionApp extends StatelessWidget {
  const FuelConsumptionApp({required this.repository, super.key});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '全能源油耗',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F766E),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7FAF9),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Color(0xFFF7FAF9),
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              side: BorderSide(color: Color(0xFFDCE7E4)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9E4E1)),
            ),
          ),
        ),
        home: DashboardScreen(repository: repository),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.repository, super.key});

  final AppRepository repository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Vehicle>>(
      stream: widget.repository.watchVehicles(),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? const <Vehicle>[];
        if (vehicles.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('全能源油耗')),
            body: const _EmptyVehicleState(),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showVehicleDialog(context),
              icon: const Icon(Icons.directions_car),
              label: const Text('添加第一辆车'),
            ),
          );
        }

        final vehicle = vehicles.firstWhere(
          (item) => item.id == _selectedVehicleId,
          orElse: () => vehicles.firstWhere(
            (item) => item.isDefault,
            orElse: () => vehicles.first,
          ),
        );
        _selectedVehicleId ??= vehicle.id;

        return StreamBuilder<List<EnergyRecord>>(
          stream: widget.repository.watchRecords(vehicle.id),
          builder: (context, recordSnapshot) {
            final records = recordSnapshot.data ?? const <EnergyRecord>[];
            final chronological = [...records]
              ..sort((a, b) => a.date.compareTo(b.date));
            final stats = EnergyStatisticsCalculator().build(
              vehicle,
              chronological,
            );
            return Scaffold(
              appBar: AppBar(
                title: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: vehicle.id,
                    items: [
                      for (final item in vehicles)
                        DropdownMenuItem(
                          value: item.id,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (id) => setState(() => _selectedVehicleId = id),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: '添加车辆',
                    onPressed: () => _showVehicleDialog(context),
                    icon: const Icon(Icons.add_road),
                  ),
                  PopupMenuButton<_DashboardAction>(
                    onSelected: (action) => _handleAction(context, action),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _DashboardAction.exportJson,
                        child: Text('导出 JSON'),
                      ),
                      PopupMenuItem(
                        value: _DashboardAction.importJson,
                        child: Text('导入 JSON'),
                      ),
                    ],
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
                children: [
                  const _SectionHeader(title: '本车概览', subtitle: '能耗、费用和补能趋势'),
                  const SizedBox(height: 10),
                  _VehicleHeader(vehicle: vehicle, recordCount: records.length),
                  const SizedBox(height: 12),
                  _MetricGrid(stats: stats),
                  const SizedBox(height: 12),
                  _TrendCard(records: chronological),
                  const SizedBox(height: 12),
                  _RecentRecords(records: records),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () =>
                    _showEnergyTypePicker(context, vehicle, chronological),
                tooltip: '新增补能',
                icon: const Icon(Icons.add),
                label: const Text('新增补能'),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showVehicleDialog(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.72,
        child: _VehicleDialog(repository: widget.repository),
      ),
    );
  }

  Future<void> _showEnergyTypePicker(
    BuildContext context,
    Vehicle vehicle,
    List<EnergyRecord> records,
  ) async {
    final selectedType = await showModalBottomSheet<EnergyType>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('选择补能类型', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final option in _allowedEnergyTypes(vehicle.type))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Icon(_energyIcon(option)),
                        ),
                        title: Text(option.label),
                        subtitle: Text(_energyDescription(option)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pop(option),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!context.mounted || selectedType == null) return;
    await _showRecordDialog(context, vehicle, selectedType, records);
  }

  Future<void> _showRecordDialog(
    BuildContext context,
    Vehicle vehicle,
    EnergyType type,
    List<EnergyRecord> records,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.88,
        child: _RecordDialog(
          repository: widget.repository,
          vehicle: vehicle,
          energyType: type,
          existingRecords: records,
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _DashboardAction action,
  ) async {
    switch (action) {
      case _DashboardAction.exportJson:
        final backup = await widget.repository.exportBackup();
        final json = BackupCodec().encode(backup);
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) =>
              _TextPayloadDialog(title: 'JSON 备份', text: json),
        );
      case _DashboardAction.importJson:
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => _ImportDialog(repository: widget.repository),
        );
    }
  }
}

enum _DashboardAction { exportJson, importJson }

class _EmptyVehicleState extends StatelessWidget {
  const _EmptyVehicleState();

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 14),
            Chip(
              avatar: Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: const Text('离线保存 · JSON 可备份'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDialog extends StatefulWidget {
  const _VehicleDialog({required this.repository});

  final AppRepository repository;

  @override
  State<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<_VehicleDialog> {
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _odometerController = TextEditingController(text: '0');
  VehicleType _type = VehicleType.fuel;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('添加车辆', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '车辆名称',
                        errorText: _error,
                      ),
                      onChanged: (_) {
                        if (_error != null) {
                          setState(() => _error = null);
                        }
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: '车型/备注'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _odometerController,
                      decoration: const InputDecoration(labelText: '初始里程 km'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final type in VehicleType.values)
                            ChoiceChip(
                              label: Text(
                                type == VehicleType.fuel ? '油车' : type.label,
                              ),
                              selected: _type == type,
                              onSelected: (_) => setState(() => _type = type),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('保存车辆'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请填写车辆名称');
      return;
    }
    await widget.repository.saveVehicle(
      Vehicle(
        id: const Uuid().v4(),
        name: name,
        type: _type,
        initialOdometerKm: double.tryParse(_odometerController.text) ?? 0,
        model: _modelController.text.trim(),
        isDefault: true,
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _VehicleHeader extends StatelessWidget {
  const _VehicleHeader({required this.vehicle, required this.recordCount});

  final Vehicle vehicle;
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primary,
              child: Icon(
                _vehicleIcon(vehicle.type),
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoPill(label: vehicle.type.label),
                      _InfoPill(
                        label:
                            '初始 ${vehicle.initialOdometerKm.toStringAsFixed(0)} km',
                      ),
                      _InfoPill(label: '$recordCount 条记录'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.stats});

  final StatisticsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        '平均能耗',
        stats.averageConsumptionLabel,
        Icons.speed,
        const Color(0xFF0F766E),
      ),
      (
        '最近一次',
        stats.latestConsumptionLabel,
        Icons.timeline,
        const Color(0xFF2563EB),
      ),
      (
        '总费用',
        '${stats.totalCost.toStringAsFixed(2)} 元',
        Icons.payments_outlined,
        const Color(0xFFB45309),
      ),
      (
        '元/公里',
        '${stats.costPerKm.toStringAsFixed(2)} 元/km',
        Icons.route_outlined,
        const Color(0xFF7C3AED),
      ),
    ];
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final childAspectRatio = textScale >= 1.3 ? 1.05 : 1.35;
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final metric in metrics)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: metric.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(metric.$3, size: 17, color: metric.$4),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          metric.$1,
                          style: Theme.of(context).textTheme.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metric.$2,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.records});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var index = 0; index < records.length; index++) {
      spots.add(FlSpot(index.toDouble(), records[index].totalCost));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '单次费用趋势',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '最近 ${records.length} 次',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: spots.length < 2
                  ? const Center(child: Text('补能两次后显示趋势'))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 3,
                            color: Theme.of(context).colorScheme.primary,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.08),
                            ),
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRecords extends StatelessWidget {
  const _RecentRecords({required this.records});

  final List<EnergyRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('暂无补能记录，记录一次后会生成费用和能耗摘要。')),
            ],
          ),
        ),
      );
    }
    final sorted = [...records]..sort((a, b) => b.date.compareTo(a.date));
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('最近记录', style: Theme.of(context).textTheme.titleMedium),
            subtitle: const Text('按时间倒序展示最近 10 条'),
          ),
          for (final record in sorted.take(10))
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _energyColor(
                  record.energyType,
                ).withValues(alpha: 0.12),
                child: Icon(
                  _energyIcon(record.energyType),
                  color: _energyColor(record.energyType),
                ),
              ),
              title: Text(
                '${record.energyType.label} · ${record.odometerKm.toStringAsFixed(0)} km',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _recordSubtitle(record),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SizedBox(
                width: 88,
                child: Text(
                  '${record.totalCost.toStringAsFixed(2)} 元',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecordDialog extends StatefulWidget {
  const _RecordDialog({
    required this.repository,
    required this.vehicle,
    required this.energyType,
    required this.existingRecords,
  });

  final AppRepository repository;
  final Vehicle vehicle;
  final EnergyType energyType;
  final List<EnergyRecord> existingRecords;

  @override
  State<_RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<_RecordDialog> {
  final _odometerController = TextEditingController();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _secondAmountController = TextEditingController();
  final _secondPriceController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isFull = true;
  ChargeMode _chargeMode = ChargeMode.slow;
  String? _error;

  @override
  void dispose() {
    _odometerController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    _secondAmountController.dispose();
    _secondPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _energyColor(
                      widget.energyType,
                    ).withValues(alpha: 0.12),
                    child: Icon(
                      _energyIcon(widget.energyType),
                      color: _energyColor(widget.energyType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.energyType.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _odometerController,
                      decoration: const InputDecoration(labelText: '当前里程 km'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: _primaryAmountLabel(widget.energyType),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: _primaryPriceLabel(widget.energyType),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    if (widget.energyType == EnergyType.hybrid) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _secondAmountController,
                        decoration: const InputDecoration(labelText: '充电量 kWh'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _secondPriceController,
                        decoration: const InputDecoration(
                          labelText: '电价 元/kWh',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                    if (widget.energyType == EnergyType.fuel)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('本次已加满'),
                        value: _isFull,
                        onChanged: (value) => setState(() => _isFull = value),
                      ),
                    if (widget.energyType == EnergyType.charge)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton<ChargeMode>(
                          segments: [
                            for (final mode in ChargeMode.values)
                              ButtonSegment(
                                value: mode,
                                label: Text(mode.label),
                              ),
                          ],
                          selected: {_chargeMode},
                          onSelectionChanged: (value) =>
                              setState(() => _chargeMode = value.single),
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: '备注'),
                      textInputAction: TextInputAction.done,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('保存记录'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final odometer = double.tryParse(_odometerController.text);
    final amount = double.tryParse(_amountController.text);
    final price = double.tryParse(_priceController.text);
    if (odometer == null || amount == null || price == null) {
      setState(() => _error = '请填写里程、数量和单价');
      return;
    }
    final secondAmount = double.tryParse(_secondAmountController.text);
    final secondPrice = double.tryParse(_secondPriceController.text);
    if (widget.energyType == EnergyType.hybrid &&
        (secondAmount == null || secondPrice == null)) {
      setState(() => _error = '请填写充电量和电价');
      return;
    }

    final record = switch (widget.energyType) {
      EnergyType.fuel => EnergyRecord.fuel(
        id: const Uuid().v4(),
        vehicleId: widget.vehicle.id,
        date: DateTime.now(),
        odometerKm: odometer,
        liters: amount,
        unitPrice: price,
        isFull: _isFull,
        note: _noteController.text.trim(),
      ),
      EnergyType.charge => EnergyRecord.charge(
        id: const Uuid().v4(),
        vehicleId: widget.vehicle.id,
        date: DateTime.now(),
        odometerKm: odometer,
        kwh: amount,
        unitPrice: price,
        chargeMode: _chargeMode,
        note: _noteController.text.trim(),
      ),
      EnergyType.hybrid => EnergyRecord.hybrid(
        id: const Uuid().v4(),
        vehicleId: widget.vehicle.id,
        date: DateTime.now(),
        odometerKm: odometer,
        liters: amount,
        fuelUnitPrice: price,
        kwh: secondAmount!,
        electricityUnitPrice: secondPrice!,
        note: _noteController.text.trim(),
      ),
    };

    final validation = RecordValidator().validate(
      record,
      widget.existingRecords,
    );
    if (!validation.isValid) {
      setState(() => _error = validation.message);
      return;
    }

    await widget.repository.saveRecord(record);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _TextPayloadDialog extends StatelessWidget {
  const _TextPayloadDialog({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 360),
        child: SingleChildScrollView(child: SelectableText(text)),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.repository});

  final AppRepository repository;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('导入 JSON'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 360),
        child: SingleChildScrollView(
          child: TextField(
            controller: _controller,
            minLines: 8,
            maxLines: 12,
            decoration: InputDecoration(
              labelText: '粘贴 JSON 备份',
              errorText: _error,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _import, child: const Text('导入')),
      ],
    );
  }

  Future<void> _import() async {
    try {
      final backup = BackupCodec().decode(_controller.text);
      await widget.repository.importBackup(backup);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      setState(() => _error = error.toString());
    }
  }
}

List<EnergyType> _allowedEnergyTypes(VehicleType vehicleType) {
  return switch (vehicleType) {
    VehicleType.fuel || VehicleType.motorcycle => [EnergyType.fuel],
    VehicleType.electric => [EnergyType.charge],
    VehicleType.hybrid => [
      EnergyType.fuel,
      EnergyType.charge,
      EnergyType.hybrid,
    ],
  };
}

IconData _vehicleIcon(VehicleType type) {
  return switch (type) {
    VehicleType.fuel => Icons.directions_car,
    VehicleType.electric => Icons.electric_car,
    VehicleType.hybrid => Icons.ev_station,
    VehicleType.motorcycle => Icons.two_wheeler,
  };
}

IconData _energyIcon(EnergyType type) {
  return switch (type) {
    EnergyType.fuel => Icons.local_gas_station,
    EnergyType.charge => Icons.bolt,
    EnergyType.hybrid => Icons.sync_alt,
  };
}

Color _energyColor(EnergyType type) {
  return switch (type) {
    EnergyType.fuel => const Color(0xFFB45309),
    EnergyType.charge => const Color(0xFF2563EB),
    EnergyType.hybrid => const Color(0xFF0F766E),
  };
}

String _recordSubtitle(EnergyRecord record) {
  final amount = switch (record.energyType) {
    EnergyType.fuel =>
      '${(record.fuelLiters ?? record.amount).toStringAsFixed(2)} L',
    EnergyType.charge =>
      '${(record.kwh ?? record.amount).toStringAsFixed(2)} kWh',
    EnergyType.hybrid =>
      '油 ${(record.fuelLiters ?? 0).toStringAsFixed(2)} L · 电 ${(record.kwh ?? 0).toStringAsFixed(2)} kWh',
  };
  if (record.note.trim().isEmpty) {
    return amount;
  }
  return '$amount · ${record.note.trim()}';
}

String _energyDescription(EnergyType type) {
  return switch (type) {
    EnergyType.fuel => '记录升数、单价和是否加满',
    EnergyType.charge => '记录电量、费用和快慢充',
    EnergyType.hybrid => '同一里程段记录油量和电量',
  };
}

String _primaryAmountLabel(EnergyType type) {
  return switch (type) {
    EnergyType.fuel => '加油量 L',
    EnergyType.charge => '充电量 kWh',
    EnergyType.hybrid => '加油量 L',
  };
}

String _primaryPriceLabel(EnergyType type) {
  return switch (type) {
    EnergyType.fuel => '油价 元/L',
    EnergyType.charge => '电价 元/kWh',
    EnergyType.hybrid => '油价 元/L',
  };
}
