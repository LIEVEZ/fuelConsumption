import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/theme/app_colors.dart';

class MineSectionCard extends StatelessWidget {
  const MineSectionCard({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const _MineSectionDivider(),
            ],
          ],
        ),
      ),
    );
  }
}

class _MineSectionDivider extends StatelessWidget {
  const _MineSectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border);
  }
}
