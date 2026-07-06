import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../../../core/icons/app_lucide_icons.dart';

// Empty state for class search/filter results on the booking screen.
class BookingEmptyState extends StatelessWidget {
  const BookingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
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
              AppLucideIcons.calendarClock,
              color: AppColors.gymGold,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Kelas tidak ditemukan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih kategori lain atau cek tanggal berikutnya.',
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
