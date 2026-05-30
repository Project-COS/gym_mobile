import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/activity_data.dart';
import 'activity_history_card.dart';

class ActivityHistorySection extends StatelessWidget {
  const ActivityHistorySection({
    super.key,
    required this.title,
    required this.countLabel,
    required this.items,
  });

  final String title;
  final String countLabel;
  final List<ActivityHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.gymGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.gymGold.withValues(alpha: 0.18),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                countLabel,
                style: const TextStyle(
                  color: AppColors.gymGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          children: List.generate(items.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 14,
              ),
              child: ActivityHistoryCard(item: items[index]),
            );
          }),
        ),
      ],
    );
  }
}
