import 'package:flutter/material.dart';
import 'package:fuel_consumption/src/widgets/mine/mine_tile_icon.dart';

class MineFeedbackSheet extends StatelessWidget {
  const MineFeedbackSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const MineTileIcon(icon: Icons.chat_bubble_outline),
                const SizedBox(width: 12),
                Text(
                  '投诉与反馈',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '写下遇到的问题或改进建议',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('感谢反馈，后续可接入本地保存')),
                  );
                },
                child: const Text('提交反馈'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
