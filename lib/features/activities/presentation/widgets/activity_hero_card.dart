import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/activity_data.dart';

// Summary card at the top of the activity screen. It receives already-computed
// stats so it stays presentational and independent from Cubit types.
class ActivityHeroCard extends StatelessWidget {
  const ActivityHeroCard({super.key, required this.stats});

  final List<ActivitySummaryStat> stats;

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
            AppColors.graphiteBlack.withValues(alpha: 0.92),
            AppColors.steelBlack.withValues(alpha: 0.88),
            AppColors.darkGold.withValues(alpha: 0.92),
          ],
          stops: const [0, 0.58, 1],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.24)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -56,
            right: -52,
            child: IgnorePointer(
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.paleGold.withValues(alpha: 0.14),
                      AppColors.paleGold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroEyebrow(),
              const SizedBox(height: 18),
              const _HeroMainContent(),
              const SizedBox(height: 18),
              _SummaryGrid(stats: stats),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroEyebrow extends StatelessWidget {
  const _HeroEyebrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.blackCore.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppLucideIcons.history, color: AppColors.gymGold, size: 15),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Riwayat aktivitas',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.gymGold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMainContent extends StatelessWidget {
  const _HeroMainContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showIcon = constraints.maxWidth >= 320;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Aktivitas',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.metallicWhite,
                      fontSize: 25,
                      height: 1.14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pantau check-in, sesi PT, dan kelas yang pernah kamu ikuti.',
                    style: TextStyle(
                      color: AppColors.silverGray,
                      fontSize: 13,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
            if (showIcon) ...[
              const SizedBox(width: 14),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.gymGold.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.gymGold.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  AppLucideIcons.activity,
                  color: AppColors.gymGold,
                  size: 29,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.stats});

  final List<ActivitySummaryStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stats.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
            child: _SummaryBox(stat: stats[index]),
          ),
        );
      }),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({required this.stat});

  final ActivitySummaryStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.blackCore.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
