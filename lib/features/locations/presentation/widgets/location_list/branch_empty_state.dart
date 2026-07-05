import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';

class BranchEmptyState extends StatelessWidget {
  const BranchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gymGold.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.wrong_location_rounded,
              color: AppColors.gymGold,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Cabang tidak ditemukan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba ubah kata pencarian atau pilih filter lain untuk melihat cabang DO GYM yang tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
