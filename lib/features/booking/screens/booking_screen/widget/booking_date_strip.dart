import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/booking_data.dart';

class BookingDateStrip extends StatelessWidget {
  const BookingDateStrip({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.onDateSelected,
  });

  final String title;
  final int selectedIndex;
  final ValueChanged<int> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.gymGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.gymGold.withValues(alpha: 0.18),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Jan 2026',
                style: TextStyle(
                  color: AppColors.gymGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: bookingDateOptions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final BookingDateOption date = bookingDateOptions[index];
              final bool isActive = selectedIndex == index;

              return _DateCard(
                date: date,
                isActive: isActive,
                onPressed: () => onDateSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.isActive,
    required this.onPressed,
  });

  final BookingDateOption date;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 74,
      decoration: BoxDecoration(
        color: isActive ? AppColors.gymGold : AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.gymGold : AppColors.gunmetal,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.gymGold.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? AppColors.blackCore : AppColors.silverGray,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                date.number,
                style: TextStyle(
                  color: isActive ? AppColors.blackCore : AppColors.silverGray,
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                date.dayName,
                style: TextStyle(
                  color: isActive ? AppColors.blackCore : AppColors.silverGray,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
