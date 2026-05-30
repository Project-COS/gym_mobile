import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

class UpcomingScheduleSection extends StatelessWidget {
  const UpcomingScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Jadwal Terdekat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  color: AppColors.gymGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.graphiteBlack,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.gunmetal),
          ),
          child: Column(
            children: [
              const _ScheduleItem(
                icon: Icons.calendar_today_rounded,
                title: 'Yoga Flow Class',
                meta: 'Hari ini • 18:00 • DO GYM Denpasar',
                badge: 'Booked',
                badgeColor: AppColors.success,
              ),
              Divider(
                height: 24,
                color: AppColors.gunmetal.withValues(alpha: 0.7),
              ),
              const _ScheduleItem(
                icon: Icons.person_rounded,
                title: 'PT Session with Budi',
                meta: 'Besok • 07:00 • Strength Training',
                badge: 'Upcoming',
                badgeColor: AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({
    required this.icon,
    required this.title,
    required this.meta,
    required this.badge,
    required this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String meta;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 360;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.steelBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gymGold.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(icon, color: AppColors.gymGold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.metallicWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    maxLines: isCompact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.silverGray,
                      fontSize: 12,
                    ),
                  ),
                  if (isCompact) ...[
                    const SizedBox(height: 10),
                    _ScheduleBadge(label: badge, color: badgeColor),
                  ],
                ],
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 12),
              _ScheduleBadge(label: badge, color: badgeColor),
            ],
          ],
        );
      },
    );
  }
}

class _ScheduleBadge extends StatelessWidget {
  const _ScheduleBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
