import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/branch_location_data.dart';
import 'branch_card.dart';

class BranchListSection extends StatelessWidget {
  const BranchListSection({
    super.key,
    required this.branches,
    required this.onDetailPressed,
    required this.onMapPressed,
  });

  final List<BranchLocation> branches;
  final ValueChanged<BranchLocation> onDetailPressed;
  final ValueChanged<BranchLocation> onMapPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Cabang Tersedia',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gymGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.gymGold.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                '${branches.length} Branch',
                style: const TextStyle(
                  color: AppColors.gymGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: branches.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final BranchLocation branch = branches[index];

            return BranchCard(
              branch: branch,
              onDetailPressed: () => onDetailPressed(branch),
              onMapPressed: () => onMapPressed(branch),
            );
          },
        ),
      ],
    );
  }
}
