import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';

class BookingHeroCard extends StatelessWidget {
  const BookingHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack,
            AppColors.steelBlack,
            AppColors.darkGold,
          ],
          stops: [0, 0.58, 1.5],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.35)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -38,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.paleGold.withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.steelBlack.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.gymGold.withValues(alpha: 0.55),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.gymGold,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'BOOKING SESSION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.gymGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Atur Jadwal Latihanmu',
                style: TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Booking sesi personal trainer atau kelas favorit seperti Pilates, Zumba, Yoga, dan HIIT di cabang DO GYM pilihanmu.',
                style: TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
