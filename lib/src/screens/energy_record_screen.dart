import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/application/record_commands.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/screens/charge_screen.dart';
import 'package:fuel_consumption/src/screens/hybrid_screen.dart';
import 'package:fuel_consumption/src/screens/refuel_screen.dart';

class EnergyRecordScreen extends StatelessWidget {
  const EnergyRecordScreen({
    required this.vehicle,
    required this.records,
    required this.onSaveRefuel,
    required this.onSaveCharge,
    required this.onSaveHybrid,
    required this.onSaved,
    super.key,
  });

  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final Future<EnergyRecord> Function(RefuelRecordInput input) onSaveRefuel;
  final Future<EnergyRecord> Function(ChargeRecordInput input) onSaveCharge;
  final Future<EnergyRecord> Function(HybridRecordInput input) onSaveHybrid;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    return switch (vehicle.type) {
      VehicleType.electric => ChargeScreen(
        key: ValueKey('charge-${vehicle.id}'),
        vehicle: vehicle,
        records: records,
        onSave: onSaveCharge,
        onSaved: onSaved,
      ),
      VehicleType.hybrid => HybridScreen(
        key: ValueKey('hybrid-${vehicle.id}'),
        vehicle: vehicle,
        records: records,
        onSave: onSaveHybrid,
        onSaved: onSaved,
      ),
      VehicleType.fuel || VehicleType.motorcycle => RefuelScreen(
        key: ValueKey('refuel-${vehicle.id}'),
        vehicle: vehicle,
        records: records,
        onSave: onSaveRefuel,
        onSaved: onSaved,
      ),
    };
  }
}
