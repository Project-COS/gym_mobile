import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/activity_data.dart';

class ActivityTabSelector extends StatelessWidget {
  const ActivityTabSelector({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  final ActivityTab activeTab;
  final ValueChanged<ActivityTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Row(
        children: ActivityTab.values.map((tab) {
          final bool isActive = activeTab == tab;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 44,
              decoration: BoxDecoration(
                color: isActive ? AppColors.gymGold : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
