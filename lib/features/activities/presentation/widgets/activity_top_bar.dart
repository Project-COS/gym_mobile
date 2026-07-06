import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

// Static heading for the activity page. It is separate so the screen can focus
// on data loading, tab state, and responsive composition.
class ActivityTopBar extends StatelessWidget {
  const ActivityTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lihat riwayat member',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.silverGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Activity',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.metallicWhite,
            fontSize: 22,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
