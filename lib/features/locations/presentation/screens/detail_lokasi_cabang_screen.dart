import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../../../classes/data/repositories/booking_class_repository.dart';
import '../../data/branch_location_data.dart';
import '../cubit/location_class_schedule_cubit.dart';
import '../widgets/location_detail/branch_cta_card.dart';
import '../widgets/location_detail/branch_detail_hero_card.dart';
import '../widgets/location_detail/branch_detail_top_bar.dart';
import '../widgets/location_detail/branch_facility_section.dart';
import '../widgets/location_detail/branch_gallery_section.dart';
import '../widgets/location_detail/branch_info_section.dart';
import '../widgets/location_detail/branch_quick_stats_grid.dart';
import '../widgets/location_detail/branch_schedule_section.dart';
import '../widgets/location_detail/branch_trainer_section.dart';

// Detail route for one branch, including contact actions and class schedule preview.
class DetailLokasiCabangScreen extends StatefulWidget {
  const DetailLokasiCabangScreen({super.key, required this.branch});

  final BranchLocation branch;

  @override
  State<DetailLokasiCabangScreen> createState() =>
      _DetailLokasiCabangScreenState();
}

class _DetailLokasiCabangScreenState extends State<DetailLokasiCabangScreen> {
  late final LocationClassScheduleCubit _scheduleCubit;

  @override
  void initState() {
    super.initState();
    // Schedule preview comes from class data, so this Cubit is scoped to the detail route.
    _scheduleCubit = LocationClassScheduleCubit(
      repository: context.read<BookingClassRepository>(),
    )..fetchSchedulesForLocation(widget.branch.id);
  }

  @override
  void didUpdateWidget(covariant DetailLokasiCabangScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.branch.id != widget.branch.id) {
      // Refresh schedules if this route is reused for a different branch.
      _scheduleCubit.fetchSchedulesForLocation(widget.branch.id);
    }
  }

  @override
  void dispose() {
    _scheduleCubit.close();
    super.dispose();
  }

  Future<void> _openMaps() async {
    final Uri mapsUri = _mapsUriForBranch(widget.branch);

    await _launchExternalUri(
      mapsUri,
      fallbackMessage: 'Maps belum bisa dibuka dari perangkat ini.',
    );
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

  Future<void> _callBranch() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: widget.branch.dialPhoneNumber,
    );

    await _launchExternalUri(
      phoneUri,
      fallbackMessage: 'Telepon belum bisa dibuka dari perangkat ini.',
    );
  }

  Future<void> _launchExternalUri(
    Uri uri, {
    required String fallbackMessage,
  }) async {
    // url_launcher failures are reported as snackbars instead of surfacing platform errors.
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
    final String shareText = '${widget.branch.name} - ${widget.branch.address}';

    // Clipboard sharing keeps this action dependency-free until native share is added.
    await Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      _showMessage('Informasi cabang disalin.');
    }
  }

  Future<void> _refreshBranchDetailSchedules() {
    return _scheduleCubit.fetchSchedulesForLocation(widget.branch.id);
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
    final BranchLocation branch = widget.branch;

    return BlocProvider<LocationClassScheduleCubit>.value(
      value: _scheduleCubit,
      child: Scaffold(
        backgroundColor: AppColors.blackCore,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final DetailLocationLayoutSpec spec =
                  DetailLocationLayoutSpec.fromWidth(constraints.maxWidth);

              return RefreshIndicator(
                color: AppColors.gymGold,
                backgroundColor: AppColors.graphiteBlack,
                onRefresh: _refreshBranchDetailSchedules,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStackedDetailContent(
    DetailLocationLayoutSpec spec,
    BranchLocation branch,
  ) {
    // Mobile and tablet detail content follows a single vertical order.
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
        if (branch.galleryImages.isNotEmpty) ...[
          SizedBox(height: spec.sectionGap),
          BranchGallerySection(images: branch.galleryImages),
        ],
        SizedBox(height: spec.sectionGap),
        BranchInfoSection(branch: branch),
        SizedBox(height: spec.sectionGap),
        BranchFacilitySection(facilities: branch.facilities),
        SizedBox(height: spec.sectionGap),
        _buildBranchClassScheduleSection(),
        if (branch.trainers.isNotEmpty) ...[
          SizedBox(height: spec.sectionGap),
          BranchTrainerSection(trainers: branch.trainers),
        ],
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
    // Wide screens keep hero/gallery/CTA beside the operational details.
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
                  if (branch.galleryImages.isNotEmpty) ...[
                    SizedBox(height: spec.sectionGap),
                    BranchGallerySection(images: branch.galleryImages),
                  ],
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
                  _buildBranchClassScheduleSection(),
                  if (branch.trainers.isNotEmpty) ...[
                    SizedBox(height: spec.sectionGap),
                    BranchTrainerSection(trainers: branch.trainers),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBranchClassScheduleSection() {
    // This section is independently loaded so branch details stay visible while
    // class schedules are fetched.
    return BlocBuilder<LocationClassScheduleCubit, LocationClassScheduleState>(
      builder: (context, scheduleState) {
        if (scheduleState.status == LocationClassScheduleStatus.loading ||
            scheduleState.status == LocationClassScheduleStatus.initial) {
          return const _BranchScheduleStatusCard.loading();
        }

        if (scheduleState.status == LocationClassScheduleStatus.failure) {
          return _BranchScheduleStatusCard.failure(
            message:
                scheduleState.errorMessage ??
                'Jadwal kelas belum bisa dimuat. Silakan coba kembali.',
            onRetryPressed: () {
              context
                  .read<LocationClassScheduleCubit>()
                  .fetchSchedulesForLocation(widget.branch.id);
            },
          );
        }

        if (scheduleState.schedules.isEmpty) {
          return const _BranchScheduleStatusCard.empty();
        }

        return BranchScheduleSection(
          schedules: scheduleState.schedules,
          onViewAllPressed: () => _showComingSoonMessage('Jadwal'),
        );
      },
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
    // Mirrors the shared breakpoints from AGENTS.md.
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

class _BranchScheduleStatusCard extends StatelessWidget {
  const _BranchScheduleStatusCard.loading()
    : message = 'Memuat jadwal kelas...',
      onRetryPressed = null,
      icon = null;

  const _BranchScheduleStatusCard.empty()
    : message = 'Belum ada kelas terjadwal di cabang ini.',
      onRetryPressed = null,
      icon = Icons.event_busy_rounded;

  const _BranchScheduleStatusCard.failure({
    required this.message,
    required this.onRetryPressed,
  }) : icon = Icons.info_rounded;

  final String message;
  final VoidCallback? onRetryPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? retryAction = onRetryPressed;
    final IconData? statusIcon = icon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Kelas',
          style: TextStyle(
            color: AppColors.metallicWhite,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.graphiteBlack.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gunmetal),
          ),
          child: Row(
            children: [
              if (statusIcon == null)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.gymGold,
                  ),
                )
              else
                Icon(statusIcon, color: AppColors.gymGold, size: 22),
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
        ),
      ],
    );
  }
}
