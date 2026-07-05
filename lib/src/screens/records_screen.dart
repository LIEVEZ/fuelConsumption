import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/utils/energy_ui.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({
    required this.records,
    required this.maintenanceRecords,
    super.key,
  });

  final List<EnergyRecord> records;
  final List<MaintenanceRecord> maintenanceRecords;

  @override
  Widget build(BuildContext context) {
    final items = <_RecordListItem>[
      for (final record in records) _RecordListItem.energy(record),
      for (final record in maintenanceRecords)
        _RecordListItem.maintenance(record),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      children: [
        const SectionHeader(title: '记录列表', subtitle: '按时间倒序展示全部用车记录'),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const _EmptyRecordsCard()
        else
          for (final item in items) ...[
            switch (item) {
              _EnergyListItem(:final record) => _RecordCard(record: record),
              _MaintenanceListItem(:final record) => _MaintenanceRecordCard(
                record: record,
              ),
            },
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

sealed class _RecordListItem {
  const _RecordListItem();

  factory _RecordListItem.energy(EnergyRecord record) = _EnergyListItem;

  factory _RecordListItem.maintenance(MaintenanceRecord record) =
      _MaintenanceListItem;

  DateTime get date;
}

class _EnergyListItem extends _RecordListItem {
  const _EnergyListItem(this.record);

  final EnergyRecord record;

  @override
  DateTime get date => record.date;
}

class _MaintenanceListItem extends _RecordListItem {
  const _MaintenanceListItem(this.record);

  final MaintenanceRecord record;

  @override
  DateTime get date => record.date;
}

class _EmptyRecordsCard extends StatelessWidget {
  const _EmptyRecordsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.list_alt_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('暂无记录，点击底部中间加号或“加油”开始记录。')),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final EnergyRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: energyColor(
                record.energyType,
              ).withValues(alpha: 0.13),
              child: Icon(
                energyIcon(record.energyType),
                color: energyColor(record.energyType),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.energyType.label} · ${record.odometerKm.toStringAsFixed(0)} km',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shortDate(record.date)} ${shortTime(record.date)} · ${recordSubtitle(record)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${record.totalCost.toStringAsFixed(2)} 元',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceRecordCard extends StatelessWidget {
  const _MaintenanceRecordCard({required this.record});

  final MaintenanceRecord record;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${shortDate(record.date)} ${shortTime(record.date)}',
      if (record.shop.isNotEmpty) record.shop,
      if (record.note.isNotEmpty) record.note,
    ].join(' · ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.maintenance.withValues(alpha: 0.13),
              child: const Icon(Icons.build, color: AppColors.maintenance),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '保养 · ${record.category.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${record.cost.toStringAsFixed(2)} 元',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
