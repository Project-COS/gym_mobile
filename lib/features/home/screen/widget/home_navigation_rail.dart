import 'package:flutter/material.dart';

import '../../../../core/colors.dart';

class HomeNavigationRail extends StatelessWidget {
  const HomeNavigationRail({
    super.key,
    required this.labels,
    required this.icons,
    required this.selectedIndex,
    required this.isExtended,
    required this.onDestinationSelected,
  });

  final List<String> labels;
  final List<IconData> icons;
  final int selectedIndex;
  final bool isExtended;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppColors.blackCore,
      selectedIndex: selectedIndex,
      extended: isExtended,
      labelType: isExtended ? null : NavigationRailLabelType.all,
      minWidth: isExtended ? 76 : 88,
      minExtendedWidth: 184,
      groupAlignment: -0.72,
      useIndicator: true,
      indicatorColor: AppColors.gymGold.withValues(alpha: 0.12),
      selectedIconTheme: const IconThemeData(
        color: AppColors.gymGold,
        size: 24,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppColors.ironGray,
        size: 24,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.metallicWhite,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppColors.ironGray,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      onDestinationSelected: onDestinationSelected,
      destinations: List.generate(labels.length, (index) {
        return NavigationRailDestination(
          icon: Icon(icons[index]),
          selectedIcon: Icon(icons[index]),
          label: Text(labels[index]),
        );
      }),
    );
  }
}
