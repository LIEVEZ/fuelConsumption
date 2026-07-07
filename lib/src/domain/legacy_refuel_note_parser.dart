class LegacyRefuelAmounts {
  const LegacyRefuelAmounts({
    this.machineAmount,
    this.paidAmount,
    this.discountAmount,
  });

  final double? machineAmount;
  final double? paidAmount;
  final double? discountAmount;

  bool get hasAny =>
      machineAmount != null || paidAmount != null || discountAmount != null;
}

class LegacyRefuelNoteParser {
  const LegacyRefuelNoteParser._();

  static LegacyRefuelAmounts parse(String note, {double? paidAmountFallback}) {
    var machineAmount = _numberAfterLabel(note, '机显金额');
    var paidAmount = _numberAfterLabel(note, '实付金额');
    var discountAmount = _numberAfterLabel(note, '优惠');

    if (paidAmount == null && machineAmount != null && discountAmount != null) {
      paidAmount = _nonNegative(machineAmount - discountAmount);
    }
    if (paidAmount == null &&
        discountAmount != null &&
        paidAmountFallback != null) {
      paidAmount = paidAmountFallback;
    }
    if (machineAmount == null && paidAmount != null && discountAmount != null) {
      machineAmount = paidAmount + discountAmount;
    }
    discountAmount ??= _discountFrom(machineAmount, paidAmount);

    return LegacyRefuelAmounts(
      machineAmount: machineAmount,
      paidAmount: paidAmount,
      discountAmount: discountAmount,
    );
  }

  static String visibleNote(String note) {
    final parts = note
        .split('·')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && !_isLegacyAmountPart(part))
        .toList();
    return parts.join(' · ');
  }

  static bool _isLegacyAmountPart(String part) {
    return _numberAfterLabel(part, '机显单价') != null ||
        _numberAfterLabel(part, '机显金额') != null ||
        _numberAfterLabel(part, '优惠') != null ||
        _numberAfterLabel(part, '实付金额') != null;
  }

  static double? _discountFrom(double? machineAmount, double? paidAmount) {
    if (machineAmount == null || paidAmount == null) return null;
    return _nonNegative(machineAmount - paidAmount);
  }

  static double _nonNegative(double value) {
    return value.clamp(0, double.infinity).toDouble();
  }

  static double? _numberAfterLabel(String text, String label) {
    final pattern = RegExp('$label\\s*[:：]?\\s*([0-9]+(?:\\.[0-9]+)?)');
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }
}
