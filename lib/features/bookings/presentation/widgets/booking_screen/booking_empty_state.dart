import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';

// Empty state for class search/filter results on the booking screen.
class BookingEmptyState extends StatelessWidget {
  const BookingEmptyState({super.key});

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
              Icons.event_busy_rounded,
              color: AppColors.gymGold,
              size: 28,
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
            'Belum ada kelas untuk kategori ini. Pilih kategori lain atau cek jadwal berikutnya.',
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
