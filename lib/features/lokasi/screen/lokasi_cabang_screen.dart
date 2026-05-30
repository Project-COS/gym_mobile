import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/colors.dart';
import 'branch_location_data.dart';
import 'detail_lokasi_cabang/detail_lokasi_cabang_screen.dart';
import 'widget/branch_empty_state.dart';
import 'widget/branch_list_section.dart';
import 'widget/branch_search_filter.dart';
import 'widget/location_hero_card.dart';
import 'widget/location_top_bar.dart';

class LokasiCabangScreen extends StatefulWidget {
  const LokasiCabangScreen({super.key});

  @override
  State<LokasiCabangScreen> createState() => _LokasiCabangScreenState();
}

class _LokasiCabangScreenState extends State<LokasiCabangScreen> {
  final TextEditingController _searchController = TextEditingController();

  BranchFilter _activeFilter = BranchFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshBranchVisibility);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshBranchVisibility)
      ..dispose();
    super.dispose();
  }

  List<BranchLocation> get _visibleBranches {
    return branchLocations.where((branch) {
      return branch.matchesKeyword(_searchController.text) &&
          branch.matchesFilter(_activeFilter);
    }).toList();
  }

  void _refreshBranchVisibility() {
    if (mounted) {
      setState(() {});
    }
  }

  void _changeActiveBranchFilter(BranchFilter filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  void _openBranchDetail(BranchLocation branch) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailLokasiCabangScreen(branch: branch),
      ),
    );
  }

  Future<void> _openMaps(String query) async {
    final Uri mapsUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });

    try {
      final bool isLaunched = await launchUrl(
        mapsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!isLaunched && mounted) {
        _showMessage('Maps belum bisa dibuka dari perangkat ini.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Maps belum bisa dibuka dari perangkat ini.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blackCore,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final LocationLayoutSpec spec = LocationLayoutSpec.fromWidth(
              constraints.maxWidth,
            );
            final List<BranchLocation> visibleBranches = _visibleBranches;

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
                          ? _buildExpandedLocationContent(spec, visibleBranches)
                          : _buildStackedLocationContent(spec, visibleBranches),
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

  Widget _buildStackedLocationContent(
    LocationLayoutSpec spec,
    List<BranchLocation> visibleBranches,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LocationTopBar(),
        SizedBox(height: spec.sectionGap),
        const LocationHeroCard(),
        SizedBox(height: spec.sectionGap),
        BranchSearchFilter(
          searchController: _searchController,
          activeFilter: _activeFilter,
          onFilterChanged: _changeActiveBranchFilter,
        ),
        SizedBox(height: spec.sectionGap),
        _buildBranchResult(visibleBranches),
      ],
    );
  }

  Widget _buildExpandedLocationContent(
    LocationLayoutSpec spec,
    List<BranchLocation> visibleBranches,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LocationTopBar(),
              SizedBox(height: spec.sectionGap),
              const LocationHeroCard(),
              SizedBox(height: spec.sectionGap),
              BranchSearchFilter(
                searchController: _searchController,
                activeFilter: _activeFilter,
                onFilterChanged: _changeActiveBranchFilter,
              ),
            ],
          ),
        ),
        SizedBox(width: spec.columnGap),
        Expanded(child: _buildBranchResult(visibleBranches)),
      ],
    );
  }

  Widget _buildBranchResult(List<BranchLocation> visibleBranches) {
    if (visibleBranches.isEmpty) {
      return const BranchEmptyState();
    }

    return BranchListSection(
      branches: visibleBranches,
      onDetailPressed: _openBranchDetail,
      onMapPressed: (branch) => _openMaps(branch.mapQuery),
    );
  }
}

class LocationLayoutSpec {
  const LocationLayoutSpec({
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

  factory LocationLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const LocationLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const LocationLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const LocationLayoutSpec(
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
