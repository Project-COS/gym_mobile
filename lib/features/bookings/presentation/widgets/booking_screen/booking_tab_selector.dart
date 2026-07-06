import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/booking_data.dart';

// Segmented control for the booking sources. Labels and icons are centralized in
// BookingTab so the screen and selector stay in sync.
class BookingTabSelector extends StatelessWidget {
  const BookingTabSelector({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  final BookingTab activeTab;
  final ValueChanged<BookingTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
      ),
      child: Row(
        children: BookingTab.values.map((tab) {
          final bool isActive = activeTab == tab;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 42,
              decoration: BoxDecoration(
                color: isActive ? AppColors.gymGold : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.gymGold.withValues(alpha: 0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: TextButton.icon(
                onPressed: () => onTabChanged(tab),
                icon: Icon(tab.icon, size: 17),
                label: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isActive
                      ? AppColors.blackCore
                      : AppColors.silverGray,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
