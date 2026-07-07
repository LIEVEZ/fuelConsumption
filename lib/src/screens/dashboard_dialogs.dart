import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/application/backup_import_service.dart';
import 'package:fuel_consumption/src/application/vehicle_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/presentation/dashboard_navigation.dart';
import 'package:fuel_consumption/src/widgets/create_record_sheet.dart';
import 'package:fuel_consumption/src/widgets/dialogs/import_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/text_payload_dialog.dart';
import 'package:fuel_consumption/src/widgets/dialogs/vehicle_dialog.dart';

Future<CreateRecordAction?> showDashboardCreateMenu({
  required BuildContext context,
  required VehicleType? vehicleType,
}) {
  return showModalBottomSheet<CreateRecordAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => CreateRecordSheet(vehicleType: vehicleType),
  );
}

Future<void> showDashboardVehicleDialog({
  required BuildContext context,
  required Future<void> Function(VehicleDraft draft) onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => VehicleDialog(onSave: onSave),
  );
}

Future<bool> confirmDashboardVehicleDelete({
  required BuildContext context,
  required Vehicle vehicle,
}) async {
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
  return confirmed ?? false;
}

Future<ImportBackupResult?> showDashboardImportDialog({
  required BuildContext context,
  required ImportDialogActions actions,
}) {
  return showDialog<ImportBackupResult>(
    context: context,
    builder: (context) => ImportDialog(actions: actions),
  );
}

Future<void> showDashboardTextPayload({
  required BuildContext context,
  required String title,
  required String text,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => TextPayloadDialog(title: title, text: text),
  );
}
