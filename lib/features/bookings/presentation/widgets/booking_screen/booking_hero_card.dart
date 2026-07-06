import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../../../core/icons/app_lucide_icons.dart';

// Static booking page hero. Data loading lives below it so the top of the page
// stays stable while PT/class lists refresh.
class BookingHeroCard extends StatelessWidget {
  const BookingHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack.withValues(alpha: 0.94),
            AppColors.steelBlack.withValues(alpha: 0.78),
            AppColors.darkGold.withValues(alpha: 0.42),
          ],
          stops: const [0, 0.68, 1],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.20)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -54,
            right: -48,
            child: IgnorePointer(
              child: Container(
                width: 152,
                height: 152,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gymGold.withValues(alpha: 0.16),
                      AppColors.gymGold.withValues(alpha: 0.05),
                      AppColors.gymGold.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.blackCore.withValues(alpha: 0.34),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.gymGold.withValues(alpha: 0.18),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppLucideIcons.calendarCheck,
                      color: AppColors.gymGold,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Jadwal latihan',
                      style: TextStyle(
                        color: AppColors.gymGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool showIcon = constraints.maxWidth >= 320;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Atur Sesi Latihan',
                              style: TextStyle(
                                color: AppColors.metallicWhite,
                                fontSize: 23,
                                height: 1.16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 9),
                            Text(
                              'Pilih sesi PT atau kelas yang tersedia di cabang DO GYM.',
                              style: TextStyle(
                                color: AppColors.silverGray,
                                fontSize: 13,
                                height: 1.52,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showIcon) ...[
                        const SizedBox(width: 18),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.gymGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.gymGold.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            AppLucideIcons.calendarPlus,
                            color: AppColors.gymGold,
                            size: 30,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
