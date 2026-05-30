import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

class WeeklyActivitySection extends StatelessWidget {
  const WeeklyActivitySection({super.key});

  static const List<_ActivityStatData> _items = [
    _ActivityStatData(
      icon: Icons.show_chart_rounded,
      label: 'Workout',
      value: '5x',
    ),
    _ActivityStatData(
      icon: Icons.access_time_rounded,
      label: 'Durasi',
      value: '6.5h',
    ),
    _ActivityStatData(
      icon: Icons.fitness_center_rounded,
      label: 'Kelas',
      value: '3x',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useTwoColumns = constraints.maxWidth < 360;
        final double spacing = useTwoColumns ? 10 : 10;
        final int columnCount = useTwoColumns ? 2 : 3;
        final double cardWidth =
            (constraints.maxWidth - (spacing * (columnCount - 1))) /
            columnCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivitas Minggu Ini',
              style: TextStyle(
                color: AppColors.metallicWhite,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _items
                  .map(
                    (item) => SizedBox(
                      width: cardWidth,
                      child: _ActivityStatCard(data: item),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityStatCard extends StatelessWidget {
  const _ActivityStatCard({required this.data});

  final _ActivityStatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.gymGold, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStatData {
  const _ActivityStatData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
