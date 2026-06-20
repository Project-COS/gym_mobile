import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../../../booking/data/repositories/booking_class_repository.dart';
import '../branch_location_data.dart';
import '../../presentation/cubit/location_class_schedule_cubit.dart';
import 'widget/branch_cta_card.dart';
import 'widget/branch_detail_hero_card.dart';
import 'widget/branch_detail_top_bar.dart';
import 'widget/branch_facility_section.dart';
import 'widget/branch_gallery_section.dart';
import 'widget/branch_info_section.dart';
import 'widget/branch_quick_stats_grid.dart';
import 'widget/branch_schedule_section.dart';
import 'widget/branch_trainer_section.dart';

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
    _scheduleCubit = LocationClassScheduleCubit(
      repository: context.read<BookingClassRepository>(),
    )..fetchSchedulesForLocation(widget.branch.id);
  }

  @override
  void didUpdateWidget(covariant DetailLokasiCabangScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.branch.id != widget.branch.id) {
      _scheduleCubit.fetchSchedulesForLocation(widget.branch.id);
    }
  }

  @override
  void dispose() {
    _scheduleCubit.close();
    super.dispose();
  }

  Future<void> _openMaps() async {
    final Uri mapsUri =
        Uri.tryParse(widget.branch.mapUrl ?? '') ??
        Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': widget.branch.mapQuery,
        });

    await _launchExternalUri(
      mapsUri,
      fallbackMessage: 'Maps belum bisa dibuka dari perangkat ini.',
    );
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

  Widget _buildBranchClassScheduleSection() {
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
          'Jadwal Hari Ini',
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
            borderRadius: BorderRadius.circular(24),
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
