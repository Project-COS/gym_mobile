import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';

// Static marketing card for the branch discovery screen.
class LocationHeroCard extends StatelessWidget {
  const LocationHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.35)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack,
            AppColors.steelBlack,
            Color(0xFF4A3315),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -44,
            right: -36,
            child: IgnorePointer(
              child: Container(
                width: 132,
                height: 132,
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
                width: double.infinity,
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
                      Icons.location_on_rounded,
                      color: AppColors.gymGold,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'DO GYM BRANCH',
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
                'Akses Semua Cabang Premium',
                style: TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pilih lokasi latihan favorit kamu. Semua cabang dilengkapi area workout, shower room, dan trainer profesional.',
                style: TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 13,
                  height: 1.7,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
