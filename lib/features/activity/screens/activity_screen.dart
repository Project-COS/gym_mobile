import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../data/activity_data.dart';
import 'widget/activity_filter_chips.dart';
import 'widget/activity_hero_card.dart';
import 'widget/activity_history_section.dart';
import 'widget/activity_tab_selector.dart';
import 'widget/activity_top_bar.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  ActivityTab _activeTab = ActivityTab.attendance;

  final Map<ActivityTab, String> _selectedFilters = {
    for (final ActivityTab tab in ActivityTab.values)
      tab: activityFilters[tab]!.first,
  };

  List<ActivityHistoryItem> get _visibleHistoryItems {
    return activityHistoryItems
        .where((item) => item.tab == _activeTab)
        .toList();
  }

  String get _activeFilter {
    return _selectedFilters[_activeTab] ?? activityFilters[_activeTab]!.first;
  }

  List<String> get _activeFilterOptions {
    return activityFilters[_activeTab] ?? const ['Semua'];
  }

  void _changeActiveTab(ActivityTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _changeActiveFilter(String filter) {
    setState(() {
      _selectedFilters[_activeTab] = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blackCore,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ActivityLayoutSpec spec = ActivityLayoutSpec.fromWidth(
              constraints.maxWidth,
            );

            return Stack(
              children: [
                Positioned(
                  top: spec.isExpanded ? -176 : -112,
                  right: spec.isExpanded ? -120 : -96,
                  child: _GlowOrb(
                    size: spec.isExpanded ? 420 : 320,
                    color: AppColors.gymGold,
                    opacity: spec.isExpanded ? 0.16 : 0.18,
                  ),
                ),
                Positioned(
                  bottom: spec.isExpanded ? -152 : -104,
                  left: spec.isExpanded ? -132 : -96,
                  child: _GlowOrb(
                    size: spec.isExpanded ? 360 : 288,
                    color: AppColors.darkGold,
                    opacity: spec.isExpanded ? 0.10 : 0.12,
                  ),
                ),
                SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: spec.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: spec.maxContentWidth,
                      ),
                      child: spec.isExpanded
                          ? _buildExpandedActivityContent(spec)
                          : _buildStackedActivityContent(spec),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStackedActivityContent(ActivityLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ActivityTopBar(),
        SizedBox(height: spec.sectionGap),
        const ActivityHeroCard(stats: activitySummaryStats),
        SizedBox(height: spec.sectionGap),
        ActivityTabSelector(
          activeTab: _activeTab,
          onTabChanged: _changeActiveTab,
        ),
        SizedBox(height: spec.sectionGap),
        _buildActiveTabContent(spec),
      ],
    );
  }

  Widget _buildExpandedActivityContent(ActivityLayoutSpec spec) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ActivityTopBar(),
              SizedBox(height: spec.sectionGap),
              const ActivityHeroCard(stats: activitySummaryStats),
              SizedBox(height: spec.sectionGap),
              ActivityTabSelector(
                activeTab: _activeTab,
                onTabChanged: _changeActiveTab,
              ),
            ],
          ),
        ),
        SizedBox(width: spec.columnGap),
        Expanded(child: _buildActiveTabContent(spec)),
      ],
    );
  }

  Widget _buildActiveTabContent(ActivityLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActivityFilterChips(
          filters: _activeFilterOptions,
          activeFilter: _activeFilter,
          onFilterChanged: _changeActiveFilter,
        ),
        SizedBox(height: spec.sectionGap),
        ActivityHistorySection(
          title: _activeTab.sectionTitle,
          countLabel: _activeTab.countLabel,
          items: _visibleHistoryItems,
        ),
      ],
    );
  }
}

class ActivityLayoutSpec {
  const ActivityLayoutSpec({
    required this.isExpanded,
    required this.maxContentWidth,
    required this.pagePadding,
    required this.sectionGap,
    required this.columnGap,
  });

  final bool isExpanded;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final double sectionGap;
  final double columnGap;

  factory ActivityLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const ActivityLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const ActivityLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const ActivityLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 18,
      columnGap: 0,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity),
              blurRadius: 70,
              spreadRadius: 42,
            ),
          ],
        ),
      ),
    );
  }
}
