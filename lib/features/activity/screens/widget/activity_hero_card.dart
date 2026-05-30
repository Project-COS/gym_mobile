import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/activity_data.dart';

class ActivityHeroCard extends StatelessWidget {
  const ActivityHeroCard({super.key, required this.stats});

  final List<ActivitySummaryStat> stats;

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
          stops: [0, 0.52, 1.5],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.35)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -56,
            right: -52,
            child: IgnorePointer(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.paleGold.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const _HeroEyebrow(),
              const SizedBox(height: 16),
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
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.steelBlack.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.55)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, color: AppColors.gymGold, size: 18),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'ACTIVITY HISTORY',
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
    );
  }
}

class _HeroMainContent extends StatelessWidget {
  const _HeroMainContent();

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 26,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Pantau riwayat kedatangan, penggunaan PT, dan kelas yang pernah kamu ikuti.',
                style: TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.gymGold.withValues(alpha: 0.24),
            ),
          ),
          child: const Icon(
            Icons.fact_check_rounded,
            color: AppColors.gymGold,
            size: 36,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blackCore.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
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
