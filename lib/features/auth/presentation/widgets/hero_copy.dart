import 'package:flutter/material.dart';

import 'package:do_gym/core/colors.dart';

// Marketing copy block for the login screen. Font sizing is supplied by the
// parent layout so the same widget works in mobile and expanded layouts.
class HeroCopy extends StatelessWidget {
  const HeroCopy({
    super.key,
    this.titleFontSize = 32,
    this.maxDescriptionWidth = 320,
  });

  final double titleFontSize;
  final double maxDescriptionWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            color: AppColors.gymGold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.84,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Masuk ke akunmu',
          style: TextStyle(
            color: AppColors.metallicWhite,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxDescriptionWidth),
          child: const Text(
            'Gunakan email yang terdaftar untuk mengakses membership DO GYM.',
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}
