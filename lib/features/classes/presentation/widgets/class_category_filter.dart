import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/class_data.dart';

// Horizontal category selector; activeCategoryId is null for "Semua".
class ClassCategoryFilter extends StatelessWidget {
  const ClassCategoryFilter({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.onCategoryChanged,
  });

  final List<ClassCategoryOption> categories;
  final String? activeCategoryId;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final ClassCategoryOption category = categories[index];
          final bool isActive = activeCategoryId == category.id;

          // AnimatedContainer gives lightweight visual feedback when filters change.
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
              onPressed: () => onCategoryChanged(category.id),
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
