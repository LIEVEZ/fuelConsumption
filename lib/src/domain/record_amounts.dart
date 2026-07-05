import 'package:fuel_consumption/src/domain/models.dart';

class RecordAmounts {
  const RecordAmounts._();

  static double totalDiscount(Iterable<EnergyRecord> records) {
    return records.fold<double>(0, (sum, record) => sum + discountFrom(record));
  }

  static double discountFrom(EnergyRecord record) {
    final explicitDiscount = _numberAfterLabel(record.note, '优惠');
    if (explicitDiscount != null) {
      return explicitDiscount;
    }

    final machineAmount = _numberAfterLabel(record.note, '机显金额');
    final paidAmount = _numberAfterLabel(record.note, '实付金额');
    if (machineAmount != null && paidAmount != null) {
      return (machineAmount - paidAmount).clamp(0, double.infinity).toDouble();
    }

    return 0;
  }

  static double? _numberAfterLabel(String text, String label) {
    final pattern = RegExp('$label\\s*([0-9]+(?:\\.[0-9]+)?)');
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }
}
