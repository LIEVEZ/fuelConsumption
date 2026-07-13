import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';

mixin RecordFormSubmitState<T extends StatefulWidget> on State<T> {
  bool saving = false;
  String? errorText;

  Future<void> submitRecord({
    required Future<void> Function() save,
    required String successMessage,
    required VoidCallback onSaved,
  }) async {
    if (saving) return;
    setState(() {
      saving = true;
      errorText = null;
    });
    try {
      await save();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      onSaved();
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => errorText = error.message);
    } on Exception {
      if (!mounted) return;
      setState(() => errorText = '保存失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
}

class RecordSaveButton extends StatelessWidget {
  const RecordSaveButton({
    required this.saving,
    required this.onPressed,
    this.height = 56,
    this.fontSize = 18,
    super.key,
  });

  final bool saving;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: saving ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.sky,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: saving
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Text(
                '保存',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class RecordFormErrorText extends StatelessWidget {
  const RecordFormErrorText({required this.error, this.padding, super.key});

  final String error;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      error,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
    final padding = this.padding;
    if (padding == null) {
      return text;
    }
    return Padding(padding: padding, child: text);
  }
}

Future<DateTime?> pickRecordDate({
  required BuildContext context,
  required DateTime current,
  bool keepTime = true,
}) async {
  final today = DateUtils.dateOnly(DateTime.now());
  final currentDate = DateUtils.dateOnly(current);
  final initialDate = currentDate.isAfter(today) ? today : currentDate;
  final picked = await showDatePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: today,
    initialDate: initialDate,
  );
  if (picked == null) return null;
  if (!keepTime) return picked;
  return DateTime(
    picked.year,
    picked.month,
    picked.day,
    current.hour,
    current.minute,
  );
}

Future<DateTime?> pickRecordTime({
  required BuildContext context,
  required DateTime current,
}) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(current),
  );
  if (picked == null) return null;
  return DateTime(
    current.year,
    current.month,
    current.day,
    picked.hour,
    picked.minute,
  );
}
