import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/booking_data.dart';

class BookingCategoryFilter extends StatelessWidget {
  const BookingCategoryFilter({
    super.key,
    required this.activeCategory,
    required this.onCategoryChanged,
  });

  final ClassCategory activeCategory;
  final ValueChanged<ClassCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ClassCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final ClassCategory category = ClassCategory.values[index];
          final bool isActive = activeCategory == category;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isActive ? AppColors.gymGold : AppColors.graphiteBlack,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isActive ? AppColors.gymGold : AppColors.gunmetal,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.gymGold.withValues(alpha: 0.16),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: TextButton(
              onPressed: () => onCategoryChanged(category),
              style: TextButton.styleFrom(
                foregroundColor: isActive
                    ? AppColors.blackCore
                    : AppColors.silverGray,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(category.label),
            ),
          );
        },
      ),
    );
  }
}
