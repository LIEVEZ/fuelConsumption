enum RefuelMachineField { unitPrice, liters, amount }

enum RefuelPaymentField { paidUnitPrice, discount, paidAmount }

class RefuelAmountValues {
  const RefuelAmountValues({
    required this.unitPrice,
    required this.liters,
    required this.machineAmount,
    required this.paidUnitPrice,
    required this.discount,
    required this.paidAmount,
  });

  final double unitPrice;
  final double liters;
  final double machineAmount;
  final double paidUnitPrice;
  final double discount;
  final double paidAmount;

  RefuelAmountValues copyWith({
    double? unitPrice,
    double? liters,
    double? machineAmount,
    double? paidUnitPrice,
    double? discount,
    double? paidAmount,
  }) {
    return RefuelAmountValues(
      unitPrice: unitPrice ?? this.unitPrice,
      liters: liters ?? this.liters,
      machineAmount: machineAmount ?? this.machineAmount,
      paidUnitPrice: paidUnitPrice ?? this.paidUnitPrice,
      discount: discount ?? this.discount,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}

class RefuelAmountCalculator {
  const RefuelAmountCalculator._();

  static RefuelAmountValues syncMachineFields(
    RefuelAmountValues values,
    RefuelMachineField lastEditedField,
  ) {
    return switch (lastEditedField) {
      RefuelMachineField.unitPrice => _syncAfterUnitPrice(values),
      RefuelMachineField.liters => _syncAfterLiters(values),
      RefuelMachineField.amount => _syncAfterMachineAmount(values),
    };
  }

  static RefuelAmountValues syncPaymentFields(
    RefuelAmountValues values,
    RefuelPaymentField lastEditedField,
  ) {
    return switch (lastEditedField) {
      RefuelPaymentField.discount => _syncAfterDiscount(values),
      RefuelPaymentField.paidAmount => _syncAfterPaidAmount(values),
      RefuelPaymentField.paidUnitPrice => _syncAfterPaidUnitPrice(values),
    };
  }

  static String formatAmount(double value) {
    if (value == 0) return '0.00';
    return value.toStringAsFixed(2);
  }

  static double paidAmountFromDiscount(double machineAmount, double discount) {
    return (machineAmount - discount).clamp(0, double.infinity).toDouble();
  }

  static RefuelAmountValues _syncAfterUnitPrice(RefuelAmountValues values) {
    if (values.unitPrice > 0 && values.liters > 0) {
      return values.copyWith(machineAmount: values.unitPrice * values.liters);
    }
    if (values.unitPrice > 0 && values.machineAmount > 0) {
      return values.copyWith(liters: values.machineAmount / values.unitPrice);
    }
    return values;
  }

  static RefuelAmountValues _syncAfterLiters(RefuelAmountValues values) {
    if (values.unitPrice > 0 && values.liters > 0) {
      return values.copyWith(machineAmount: values.unitPrice * values.liters);
    }
    if (values.liters > 0 && values.machineAmount > 0) {
      return values.copyWith(unitPrice: values.machineAmount / values.liters);
    }
    return values;
  }

  static RefuelAmountValues _syncAfterMachineAmount(RefuelAmountValues values) {
    if (values.unitPrice > 0 && values.machineAmount > 0) {
      return values.copyWith(liters: values.machineAmount / values.unitPrice);
    }
    if (values.liters > 0 && values.machineAmount > 0) {
      return values.copyWith(unitPrice: values.machineAmount / values.liters);
    }
    return values;
  }

  static RefuelAmountValues _syncAfterDiscount(RefuelAmountValues values) {
    final paidAmount = paidAmountFromDiscount(
      values.machineAmount,
      values.discount,
    );
    return values.copyWith(
      paidAmount: paidAmount,
      paidUnitPrice: values.liters > 0 ? paidAmount / values.liters : null,
    );
  }

  static RefuelAmountValues _syncAfterPaidAmount(RefuelAmountValues values) {
    final discount = paidAmountFromDiscount(
      values.machineAmount,
      values.paidAmount,
    );
    return values.copyWith(
      discount: discount,
      paidUnitPrice: values.liters > 0
          ? values.paidAmount / values.liters
          : null,
    );
  }

  static RefuelAmountValues _syncAfterPaidUnitPrice(RefuelAmountValues values) {
    if (values.paidUnitPrice <= 0 || values.liters <= 0) {
      return values;
    }
    final paidAmount = values.paidUnitPrice * values.liters;
    return values.copyWith(
      paidAmount: paidAmount,
      discount: paidAmountFromDiscount(values.machineAmount, paidAmount),
    );
  }
}
