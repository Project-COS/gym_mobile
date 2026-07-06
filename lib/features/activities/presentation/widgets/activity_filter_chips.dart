import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

// Horizontal filter control reused by all activity tabs. The screen decides
// whether a filter is server-backed or applied locally.
class ActivityFilterChips extends StatelessWidget {
  const ActivityFilterChips({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final String filter = filters[index];
          final bool isActive = activeFilter == filter;

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
              onPressed: () => onFilterChanged(filter),
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
              child: Text(filter),
            ),
          );
        },
      ),
    );
  }
}
