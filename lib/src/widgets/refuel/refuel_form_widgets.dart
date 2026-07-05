import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class RefuelFormSection extends StatelessWidget {
  const RefuelFormSection({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(children: children),
    );
  }
}

class RefuelValueRow extends StatelessWidget {
  const RefuelValueRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.required = false,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      title: _RequiredLabel(label: label, required: required),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const Icon(Icons.chevron_right, size: 32),
        ],
      ),
      onTap: onTap,
    );
  }
}

class RefuelInputRow extends StatelessWidget {
  const RefuelInputRow({
    required this.label,
    required this.controller,
    this.suffix,
    this.required = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? suffix;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _RequiredLabel(label: label, required: required),
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(suffixText: suffix),
            ),
          ),
        ],
      ),
    );
  }
}

class RefuelCompactInput extends StatelessWidget {
  const RefuelCompactInput({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onTap: () {
        if (controller.text == '0.00') {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      },
      decoration: const InputDecoration(contentPadding: EdgeInsets.all(16)),
    );
  }
}

class RefuelFieldColumn extends StatelessWidget {
  const RefuelFieldColumn({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class RefuelSegmentRow extends StatelessWidget {
  const RefuelSegmentRow({
    required this.label,
    required this.leftLabel,
    required this.rightLabel,
    required this.selectedRight,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String leftLabel;
  final String rightLabel;
  final bool selectedRight;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          _SegmentButton(
            label: leftLabel,
            selected: !selectedRight,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 8),
          _SegmentButton(
            label: rightLabel,
            selected: selectedRight,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class RefuelOptionalSection extends StatelessWidget {
  const RefuelOptionalSection({
    required this.fuelGrade,
    required this.onFuelGradeTap,
    super.key,
  });

  final String fuelGrade;
  final VoidCallback onFuelGradeTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SectionHeader(title: '选填项'),
            const SizedBox(height: 16),
            const _OptionTile(label: '加油站', value: ''),
            const Divider(height: 1),
            _OptionTile(label: '燃油标号', value: fuelGrade, onTap: onFuelGradeTap),
          ],
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: AppColors.danger)),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        width: 90,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.sky : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty) Text(value),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
