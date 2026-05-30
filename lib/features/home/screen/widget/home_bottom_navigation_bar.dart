import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    super.key,
    required this.labels,
    required this.icons,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<String> labels;
  final List<IconData> icons;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.blackCore,
        border: Border(top: BorderSide(color: AppColors.gunmetal, width: 1)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final bool isActive = selectedIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onDestinationSelected(index),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.gymGold.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      size: 23,
                      color: isActive ? AppColors.gymGold : AppColors.ironGray,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.metallicWhite
                            : AppColors.ironGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
