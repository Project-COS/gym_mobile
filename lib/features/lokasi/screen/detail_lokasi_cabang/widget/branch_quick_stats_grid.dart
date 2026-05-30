import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../branch_location_data.dart';

class BranchQuickStatsGrid extends StatelessWidget {
  const BranchQuickStatsGrid({super.key, required this.branch});

  final BranchLocation branch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.schedule_rounded,
            label: 'Jam Buka',
            value: branch.hours,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.navigation_rounded,
            label: 'Jarak',
            value: branch.distance,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.groups_rounded,
            label: 'Kapasitas',
            value: branch.capacity,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gymGold.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, color: AppColors.gymGold, size: 17),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
