import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../../data/branch_location_data.dart';
import '../../data/repositories/location_repository.dart';
import '../cubit/location_cubit.dart';
import '../widgets/location_list/branch_card.dart';
import '../widgets/location_list/branch_empty_state.dart';
import '../widgets/location_list/branch_list_section.dart';
import '../widgets/location_list/branch_search_filter.dart';
import '../widgets/location_list/location_hero_card.dart';
import '../widgets/location_list/location_top_bar.dart';
import 'detail_lokasi_cabang_screen.dart';

// API-backed branch list screen used by the Home navigation tab.
class LokasiCabangScreen extends StatefulWidget {
  const LokasiCabangScreen({super.key});

  @override
  State<LokasiCabangScreen> createState() => _LokasiCabangScreenState();
}

class _LokasiCabangScreenState extends State<LokasiCabangScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationCubit>(
      // The Cubit is route-scoped because this screen owns the branch list load.
      create: (context) =>
          LocationCubit(repository: context.read<LocationRepository>())
            ..fetchLocations(),
      child: const _LokasiCabangView(),
    );
  }
}

class _LokasiCabangView extends StatefulWidget {
  const _LokasiCabangView();

  @override
  State<_LokasiCabangView> createState() => _LokasiCabangViewState();
}

class _LokasiCabangViewState extends State<_LokasiCabangView> {
  final TextEditingController _searchController = TextEditingController();

  BranchFilter _activeFilter = BranchFilter.all;

  @override
  void initState() {
    super.initState();
    // Search only affects local visibility after the branch list is loaded.
    _searchController.addListener(_refreshBranchVisibility);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshBranchVisibility)
      ..dispose();
    super.dispose();
  }

  List<BranchLocation> _filterVisibleBranches(
    List<BranchLocation> branches,
    BranchFilter activeFilter,
  ) {
    // Keyword and filter are applied client-side to the current API result.
    return branches.where((branch) {
      return branch.matchesKeyword(_searchController.text) &&
          branch.matchesFilter(activeFilter);
    }).toList();
  }

  List<BranchFilter> _availableFilters(List<BranchLocation> branches) {
    return [
      BranchFilter.all,
      if (branches.any((branch) => branch.isNearest)) BranchFilter.nearest,
      if (branches.any((branch) => branch.hasKnownOpenStatus))
        BranchFilter.open,
      if (branches.any((branch) => branch.isTwentyFourHours))
        BranchFilter.twentyFourHours,
    ];
  }

  BranchFilter _effectiveActiveFilter(List<BranchFilter> availableFilters) {
    if (availableFilters.contains(_activeFilter)) {
      return _activeFilter;
    }

    return BranchFilter.all;
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

  Future<void> _openMaps(BranchLocation branch) async {
    final Uri mapsUri = _mapsUriForBranch(branch);

    // Prefer backend map URL, then fall back to a Google Maps search query.
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

  Uri _mapsUriForBranch(BranchLocation branch) {
    final rawMapUrl = branch.mapUrl?.trim();

    if (rawMapUrl != null && rawMapUrl.isNotEmpty) {
      final parsedMapUrl = Uri.tryParse(rawMapUrl);

      if (parsedMapUrl != null && parsedMapUrl.hasScheme) {
        return parsedMapUrl;
      }
    }

    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': branch.mapQuery,
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        return ColoredBox(
          color: AppColors.blackCore,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final LocationLayoutSpec spec = LocationLayoutSpec.fromWidth(
                  constraints.maxWidth,
                );
                final List<BranchFilter> availableFilters = _availableFilters(
                  locationState.locations,
                );
                final BranchFilter effectiveActiveFilter =
                    _effectiveActiveFilter(availableFilters);
                final List<BranchLocation> visibleBranches =
                    _filterVisibleBranches(
                      locationState.locations,
                      effectiveActiveFilter,
                    );

                return CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: spec.isExpanded
                      ? _buildExpandedLocationSlivers(
                          spec,
                          locationState,
                          visibleBranches,
                          availableFilters,
                          effectiveActiveFilter,
                        )
                      : _buildStackedLocationSlivers(
                          spec,
                          locationState,
                          visibleBranches,
                          availableFilters,
                          effectiveActiveFilter,
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildStackedLocationSlivers(
    LocationLayoutSpec spec,
    LocationState locationState,
    List<BranchLocation> visibleBranches,
    List<BranchFilter> availableFilters,
    BranchFilter activeFilter,
  ) {
    // Mobile and tablet keep search controls above the result list.
    return [
      _buildContentSliver(
        spec,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LocationTopBar(),
            SizedBox(height: spec.sectionGap),
            const LocationHeroCard(),
            SizedBox(height: spec.sectionGap),
            BranchSearchFilter(
              searchController: _searchController,
              activeFilter: activeFilter,
              filters: availableFilters,
              onFilterChanged: _changeActiveBranchFilter,
            ),
          ],
        ),
        top: spec.pagePadding.top,
        bottom: spec.sectionGap,
      ),
      ..._buildBranchResultSlivers(spec, locationState, visibleBranches),
    ];
  }

  List<Widget> _buildExpandedLocationSlivers(
    LocationLayoutSpec spec,
    LocationState locationState,
    List<BranchLocation> visibleBranches,
    List<BranchFilter> availableFilters,
    BranchFilter activeFilter,
  ) {
    final bool hasBranchList = _hasBranchList(locationState, visibleBranches);

    // Wide screens keep discovery controls on the left and results on the right.
    return [
      _buildContentSliver(
        spec,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: spec.sidePanelWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LocationTopBar(),
                  SizedBox(height: spec.sectionGap),
                  const LocationHeroCard(),
                  SizedBox(height: spec.sectionGap),
                  BranchSearchFilter(
                    searchController: _searchController,
                    activeFilter: activeFilter,
                    filters: availableFilters,
                    onFilterChanged: _changeActiveBranchFilter,
                  ),
                ],
              ),
            ),
            SizedBox(width: spec.columnGap),
            Expanded(
              child: _buildBranchResultTop(locationState, visibleBranches),
            ),
          ],
        ),
        top: spec.pagePadding.top,
        bottom: hasBranchList ? 0 : spec.pagePadding.bottom,
      ),
      if (hasBranchList)
        _buildBranchCardListSliver(
          spec,
          visibleBranches,
          alignWithExpandedResults: true,
        ),
    ];
  }

  List<Widget> _buildBranchResultSlivers(
    LocationLayoutSpec spec,
    LocationState locationState,
    List<BranchLocation> visibleBranches,
  ) {
    if (!_hasBranchList(locationState, visibleBranches)) {
      return [
        _buildContentSliver(
          spec,
          _buildBranchResultTop(locationState, visibleBranches),
          bottom: spec.pagePadding.bottom,
        ),
      ];
    }

    return [
      _buildContentSliver(
        spec,
        BranchListHeader(branchCount: visibleBranches.length),
      ),
      _buildBranchCardListSliver(spec, visibleBranches),
    ];
  }

  Widget _buildBranchResultTop(
    LocationState locationState,
    List<BranchLocation> visibleBranches,
  ) {
    if (locationState.status == LocationLoadStatus.loading ||
        locationState.status == LocationLoadStatus.initial) {
      return const _LocationStatusCard.loading();
    }

    if (locationState.status == LocationLoadStatus.failure) {
      return _LocationStatusCard.failure(
        message:
            locationState.errorMessage ??
            'Lokasi belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: context.read<LocationCubit>().fetchLocations,
      );
    }

    if (visibleBranches.isEmpty) {
      return const BranchEmptyState();
    }

    return BranchListHeader(branchCount: visibleBranches.length);
  }

  bool _hasBranchList(
    LocationState locationState,
    List<BranchLocation> visibleBranches,
  ) {
    return locationState.status == LocationLoadStatus.success &&
        visibleBranches.isNotEmpty;
  }

  Widget _buildContentSliver(
    LocationLayoutSpec spec,
    Widget child, {
    double top = 0,
    double bottom = 0,
  }) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        spec.pagePadding.left,
        top,
        spec.pagePadding.right,
        bottom,
      ),
      sliver: SliverToBoxAdapter(child: _buildConstrainedContent(spec, child)),
    );
  }

  Widget _buildBranchCardListSliver(
    LocationLayoutSpec spec,
    List<BranchLocation> branches, {
    bool alignWithExpandedResults = false,
  }) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        spec.pagePadding.left,
        0,
        spec.pagePadding.right,
        spec.pagePadding.bottom,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final BranchLocation branch = branches[index];
          final Widget branchCard = BranchCard(
            branch: branch,
            onDetailPressed: () => _openBranchDetail(branch),
            onMapPressed: () => _openMaps(branch),
          );

          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 12 : 14),
            child: _buildConstrainedContent(
              spec,
              alignWithExpandedResults
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: spec.sidePanelWidth),
                        SizedBox(width: spec.columnGap),
                        Expanded(child: branchCard),
                      ],
                    )
                  : branchCard,
            ),
          );
        }, childCount: branches.length),
      ),
    );
  }

  Widget _buildConstrainedContent(LocationLayoutSpec spec, Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
        child: child,
      ),
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
    required this.sidePanelWidth,
  });

  final bool isExpanded;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final double sectionGap;
  final double columnGap;
  final double sidePanelWidth;

  factory LocationLayoutSpec.fromWidth(double width) {
    // Mirrors the shared breakpoints from AGENTS.md.
    if (width >= 840) {
      return const LocationLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
        sidePanelWidth: 348,
      );
    }

    if (width >= 600) {
      return const LocationLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
        sidePanelWidth: 0,
      );
    }

    return const LocationLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 18,
      columnGap: 0,
      sidePanelWidth: 0,
    );
  }
}

class _LocationStatusCard extends StatelessWidget {
  const _LocationStatusCard.loading()
    : message = 'Memuat lokasi cabang...',
      onRetryPressed = null;

  const _LocationStatusCard.failure({
    required this.message,
    required this.onRetryPressed,
  });

  final String message;
  final VoidCallback? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? retryAction = onRetryPressed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Row(
        children: [
          if (retryAction == null)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.gymGold,
              ),
            )
          else
            const Icon(Icons.info_rounded, color: AppColors.gymGold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.silverGray,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (retryAction != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: retryAction,
              child: const Text(
                'Coba lagi',
                style: TextStyle(
                  color: AppColors.gymGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
