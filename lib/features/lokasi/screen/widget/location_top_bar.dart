import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

class LocationTopBar extends StatelessWidget {
  const LocationTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temukan cabang terdekat',
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
          'Lokasi Branch',
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
