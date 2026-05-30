import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../branch_location_data.dart';
import 'widget/branch_cta_card.dart';
import 'widget/branch_detail_hero_card.dart';
import 'widget/branch_detail_top_bar.dart';
import 'widget/branch_facility_section.dart';
import 'widget/branch_info_section.dart';
import 'widget/branch_quick_stats_grid.dart';
import 'widget/branch_schedule_section.dart';
import 'widget/branch_trainer_section.dart';

class DetailLokasiCabangScreen extends StatefulWidget {
  const DetailLokasiCabangScreen({super.key, this.branch});

  final BranchLocation? branch;

  @override
  State<DetailLokasiCabangScreen> createState() =>
      _DetailLokasiCabangScreenState();
}

class _DetailLokasiCabangScreenState extends State<DetailLokasiCabangScreen> {
  BranchLocation get _branch => widget.branch ?? branchLocations.first;

  Future<void> _openMaps() async {
    final Uri mapsUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': _branch.mapQuery,
    });

    await _launchExternalUri(
      mapsUri,
      fallbackMessage: 'Maps belum bisa dibuka dari perangkat ini.',
    );
  }

  Future<void> _callBranch() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _branch.dialPhoneNumber);

    await _launchExternalUri(
      phoneUri,
      fallbackMessage: 'Telepon belum bisa dibuka dari perangkat ini.',
    );
  }

  Future<void> _launchExternalUri(
    Uri uri, {
    required String fallbackMessage,
  }) async {
    try {
      final bool isLaunched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!isLaunched && mounted) {
        _showMessage(fallbackMessage);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(fallbackMessage);
      }
    }
  }

  Future<void> _shareBranch() async {
    final String shareText = '${_branch.name} - ${_branch.address}';

    await Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      _showMessage('Informasi branch disalin.');
    }
  }

  void _showComingSoonMessage(String featureName) {
    _showMessage('$featureName belum tersedia di versi ini.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final BranchLocation branch = _branch;

    return Scaffold(
      backgroundColor: AppColors.blackCore,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final DetailLocationLayoutSpec spec =
                DetailLocationLayoutSpec.fromWidth(constraints.maxWidth);

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
                          ? _buildExpandedDetailContent(spec, branch)
                          : _buildStackedDetailContent(spec, branch),
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

  Widget _buildStackedDetailContent(
    DetailLocationLayoutSpec spec,
    BranchLocation branch,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BranchDetailTopBar(
          onBackPressed: () => Navigator.of(context).pop(),
          onSharePressed: _shareBranch,
        ),
        SizedBox(height: spec.sectionGap),
        BranchDetailHeroCard(
          branch: branch,
          onCallPressed: _callBranch,
          onMapPressed: _openMaps,
        ),
        SizedBox(height: spec.sectionGap),
        BranchQuickStatsGrid(branch: branch),
        SizedBox(height: spec.sectionGap),
        BranchInfoSection(branch: branch),
        SizedBox(height: spec.sectionGap),
        BranchFacilitySection(facilities: branch.facilities),
        SizedBox(height: spec.sectionGap),
        BranchScheduleSection(
          schedules: branch.schedules,
          onViewAllPressed: () => _showComingSoonMessage('Jadwal'),
        ),
        SizedBox(height: spec.sectionGap),
        BranchTrainerSection(trainers: branch.trainers),
        SizedBox(height: spec.sectionGap),
        BranchCtaCard(
          branch: branch,
          onCheckInPressed: () => _showComingSoonMessage('Check-in'),
          onBookingPressed: () => _showComingSoonMessage('Booking'),
        ),
      ],
    );
  }

  Widget _buildExpandedDetailContent(
    DetailLocationLayoutSpec spec,
    BranchLocation branch,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BranchDetailTopBar(
          onBackPressed: () => Navigator.of(context).pop(),
          onSharePressed: _shareBranch,
        ),
        SizedBox(height: spec.sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 390,
              child: Column(
                children: [
                  BranchDetailHeroCard(
                    branch: branch,
                    onCallPressed: _callBranch,
                    onMapPressed: _openMaps,
                  ),
                  SizedBox(height: spec.sectionGap),
                  BranchQuickStatsGrid(branch: branch),
                  SizedBox(height: spec.sectionGap),
                  BranchCtaCard(
                    branch: branch,
                    onCheckInPressed: () => _showComingSoonMessage('Check-in'),
                    onBookingPressed: () => _showComingSoonMessage('Booking'),
                  ),
                ],
              ),
            ),
            SizedBox(width: spec.columnGap),
            Expanded(
              child: Column(
                children: [
                  BranchInfoSection(branch: branch),
                  SizedBox(height: spec.sectionGap),
                  BranchFacilitySection(facilities: branch.facilities),
                  SizedBox(height: spec.sectionGap),
                  BranchScheduleSection(
                    schedules: branch.schedules,
                    onViewAllPressed: () => _showComingSoonMessage('Jadwal'),
                  ),
                  SizedBox(height: spec.sectionGap),
                  BranchTrainerSection(trainers: branch.trainers),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DetailLocationLayoutSpec {
  const DetailLocationLayoutSpec({
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

  factory DetailLocationLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const DetailLocationLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const DetailLocationLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const DetailLocationLayoutSpec(
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
