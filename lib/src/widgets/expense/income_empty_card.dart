import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';
import 'package:fuel_consumption/src/widgets/section_header.dart';

class IncomeEmptyCard extends StatelessWidget {
  const IncomeEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '收入年度统计'),
            const SizedBox(height: 18),
            Container(
              height: 118,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mutedSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '暂无收入记录',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSubtle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
