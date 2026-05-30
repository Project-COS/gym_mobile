import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

class MembershipRenewalCard extends StatelessWidget {
  const MembershipRenewalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack,
            AppColors.steelBlack,
            AppColors.gymGold.withValues(alpha: 0.22),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.paleGold,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Membership Renewal',
              style: TextStyle(
                color: AppColors.blackCore,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Perpanjang Membership Tanpa Ribet',
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jaga akses latihan tetap aktif dengan perpanjangan membership di cabang DO GYM terdekat.',
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gymGold,
                foregroundColor: AppColors.blackCore,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cek Gym Terdekat',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
