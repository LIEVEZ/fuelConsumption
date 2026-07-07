import 'package:fuel_consumption/src/domain/models.dart';
import 'package:fuel_consumption/src/domain/legacy_refuel_note_parser.dart';

class RecordAmounts {
  const RecordAmounts._();

  static double totalDiscount(Iterable<EnergyRecord> records) {
    return records.fold<double>(0, (sum, record) => sum + discountFrom(record));
  }

  static double discountFrom(EnergyRecord record) {
    final structuredDiscount = record.discountAmount;
    if (structuredDiscount != null) {
      return structuredDiscount;
    }
    final structuredMachineAmount = record.machineAmount;
    final structuredPaidAmount = record.paidAmount;
    if (structuredMachineAmount != null && structuredPaidAmount != null) {
      return (structuredMachineAmount - structuredPaidAmount)
          .clamp(0, double.infinity)
          .toDouble();
    }

    return LegacyRefuelNoteParser.parse(
          record.note,
          paidAmountFallback: record.totalCost,
        ).discountAmount ??
        0;
  }
}
