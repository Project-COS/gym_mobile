import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../../data/branch_location_data.dart';
import '../../data/repositories/location_repository.dart';
import '../cubit/location_cubit.dart';
import '../widgets/location_list/branch_empty_state.dart';
import '../widgets/location_list/branch_list_section.dart';
import '../widgets/location_list/branch_search_filter.dart';
import '../widgets/location_list/location_hero_card.dart';
import '../widgets/location_list/location_top_bar.dart';
import 'detail_lokasi_cabang_screen.dart';

class LokasiCabangScreen extends StatefulWidget {
  const LokasiCabangScreen({super.key});

  @override
  State<LokasiCabangScreen> createState() => _LokasiCabangScreenState();
}

class _LokasiCabangScreenState extends State<LokasiCabangScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationCubit>(
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
    _searchController.addListener(_refreshBranchVisibility);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshBranchVisibility)
      ..dispose();
    super.dispose();
  }

  List<BranchLocation> _filterVisibleBranches(List<BranchLocation> branches) {
    return branches.where((branch) {
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

  Future<void> _openMaps(BranchLocation branch) async {
    final Uri mapsUri =
        Uri.tryParse(branch.mapUrl ?? '') ??
        Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': branch.mapQuery,
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
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        return Container(
          color: AppColors.blackCore,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final LocationLayoutSpec spec = LocationLayoutSpec.fromWidth(
                  constraints.maxWidth,
                );
                final List<BranchLocation> visibleBranches =
                    _filterVisibleBranches(locationState.locations);

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
                              ? _buildExpandedLocationContent(
                                  spec,
                                  locationState,
                                  visibleBranches,
                                )
                              : _buildStackedLocationContent(
                                  spec,
                                  locationState,
                                  visibleBranches,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStackedLocationContent(
    LocationLayoutSpec spec,
    LocationState locationState,
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
        _buildBranchResult(locationState, visibleBranches),
      ],
    );
  }

  Widget _buildExpandedLocationContent(
    LocationLayoutSpec spec,
    LocationState locationState,
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
        Expanded(child: _buildBranchResult(locationState, visibleBranches)),
      ],
    );
  }

  Widget _buildBranchResult(
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

    return BranchListSection(
      branches: visibleBranches,
      onDetailPressed: _openBranchDetail,
      onMapPressed: _openMaps,
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
