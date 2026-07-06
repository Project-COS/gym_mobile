import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/member_attendance_activity_mapper.dart';
import '../../data/repositories/member_attendance_activity_repository.dart';
import '../cubit/member_attendance_activity_cubit.dart';
import '../../../bookings/data/repositories/personal_training_booking_repository.dart';
import '../../../bookings/presentation/cubit/personal_training_booking_history_cubit.dart';
import '../../../bookings/presentation/screens/booking_success_screen.dart';
import '../../../classes/data/repositories/booking_class_repository.dart';
import '../../../classes/presentation/cubit/class_booking_history_cubit.dart';
import '../../data/activity_data.dart';
import '../../data/class_booking_activity_mapper.dart';
import '../../data/personal_training_activity_mapper.dart';
import '../widgets/activity_filter_chips.dart';
import '../widgets/activity_hero_card.dart';
import '../widgets/activity_history_section.dart';
import '../widgets/activity_tab_selector.dart';
import '../widgets/activity_top_bar.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, this.isActive = false});

  // The home shell passes this flag so activity data is fetched only when the
  // user can actually see the tab.
  final bool isActive;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const PersonalTrainingBookingHistoryFilter
  _personalTrainingActivityFilter = PersonalTrainingBookingHistoryFilter.all;
  static const ClassBookingHistoryFilter _classActivityFilter =
      ClassBookingHistoryFilter.all;

  ActivityTab _activeTab = ActivityTab.attendance;
  MemberAttendanceActivityRepository? _memberAttendanceActivityRepository;
  MemberAttendanceActivityCubit? _memberAttendanceActivityCubit;
  PersonalTrainingBookingRepository? _personalTrainingBookingRepository;
  PersonalTrainingBookingHistoryCubit? _personalTrainingBookingHistoryCubit;
  BookingClassRepository? _bookingClassRepository;
  ClassBookingHistoryCubit? _classBookingHistoryCubit;

  final Map<ActivityTab, String> _selectedFilters = {
    for (final ActivityTab tab in ActivityTab.values)
      tab: activityFilters[tab]!.first,
  };

  String get _activeFilter {
    return _selectedFilters[_activeTab] ?? activityFilters[_activeTab]!.first;
  }

  List<String> get _activeFilterOptions {
    return activityFilters[_activeTab] ?? const ['Semua'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Activity composes data from three owning features. Recreate local cubits
    // only when their injected repositories change.
    final attendanceRepository = context
        .read<MemberAttendanceActivityRepository>();
    final personalTrainingRepository = context
        .read<PersonalTrainingBookingRepository>();
    final bookingClassRepository = context.read<BookingClassRepository>();

    if (_memberAttendanceActivityRepository != attendanceRepository ||
        _memberAttendanceActivityCubit == null) {
      _memberAttendanceActivityCubit?.close();
      _memberAttendanceActivityRepository = attendanceRepository;
      _memberAttendanceActivityCubit = MemberAttendanceActivityCubit(
        repository: attendanceRepository,
      );
    }

    if (_personalTrainingBookingRepository != personalTrainingRepository ||
        _personalTrainingBookingHistoryCubit == null) {
      _personalTrainingBookingHistoryCubit?.close();
      _personalTrainingBookingRepository = personalTrainingRepository;
      _personalTrainingBookingHistoryCubit =
          PersonalTrainingBookingHistoryCubit(
            repository: personalTrainingRepository,
          );
    }

    if (_bookingClassRepository != bookingClassRepository ||
        _classBookingHistoryCubit == null) {
      _classBookingHistoryCubit?.close();
      _bookingClassRepository = bookingClassRepository;
      _classBookingHistoryCubit = ClassBookingHistoryCubit(
        repository: bookingClassRepository,
      );
    }

    if (widget.isActive) {
      _fetchActivityDataIfNeeded();
    }
  }

  @override
  void didUpdateWidget(covariant ActivityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _fetchActivityDataIfNeeded();
    }
  }

  @override
  void dispose() {
    _memberAttendanceActivityCubit?.close();
    _personalTrainingBookingHistoryCubit?.close();
    _classBookingHistoryCubit?.close();
    super.dispose();
  }

  void _changeActiveTab(ActivityTab tab) {
    setState(() {
      _activeTab = tab;
    });

    if (tab == ActivityTab.attendance) {
      // Each tab loads lazily the first time it is opened.
      _fetchAttendanceActivityIfNeeded();
    } else if (tab == ActivityTab.personalTrainer) {
      _fetchPersonalTrainingActivityIfNeeded();
    } else if (tab == ActivityTab.classSession) {
      _fetchClassActivityIfNeeded();
    }
  }

  void _changeActiveFilter(String filter) {
    setState(() {
      _selectedFilters[_activeTab] = filter;
    });

    // Attendance filters are server-backed. PT and class currently filter their
    // already-loaded history locally in this screen.
    if (_activeTab == ActivityTab.attendance) {
      _memberAttendanceActivityCubit?.fetchAttendances(
        filter: _attendanceFilterFromLabel(filter),
        forceRefresh: true,
      );
    }
  }

  Future<void> _refreshActiveTab() {
    // RefreshIndicator expects the returned Future to complete when refresh work
    // is done, so each tab delegates to the matching Cubit request.
    if (_activeTab == ActivityTab.attendance) {
      return _memberAttendanceActivityCubit?.fetchAttendances(
            filter: _attendanceFilterFromLabel(_activeFilter),
            forceRefresh: true,
          ) ??
          Future<void>.value();
    }

    if (_activeTab == ActivityTab.personalTrainer) {
      return _personalTrainingBookingHistoryCubit?.fetchBookings(
            filter: _personalTrainingActivityFilter,
            forceRefresh: true,
          ) ??
          Future<void>.value();
    }

    if (_activeTab == ActivityTab.classSession) {
      return _classBookingHistoryCubit?.fetchBookings(
            filter: _classActivityFilter,
            forceRefresh: true,
          ) ??
          Future<void>.value();
    }

    return Future<void>.value();
  }

  void _fetchPersonalTrainingActivityIfNeeded() {
    final cubit = _personalTrainingBookingHistoryCubit;

    if (cubit == null ||
        cubit.state.status !=
            PersonalTrainingBookingHistoryLoadStatus.initial) {
      return;
    }

    cubit.fetchBookings(filter: _personalTrainingActivityFilter);
  }

  void _fetchActivityDataIfNeeded() {
    // When the Activity tab becomes visible, prefetch all three summaries so the
    // hero card can show counts without waiting for each tab to be opened.
    _fetchAttendanceActivityIfNeeded();
    _fetchPersonalTrainingActivityIfNeeded();
    _fetchClassActivityIfNeeded();
  }

  void _fetchAttendanceActivityIfNeeded() {
    final cubit = _memberAttendanceActivityCubit;

    if (cubit == null ||
        cubit.state.status != MemberAttendanceActivityLoadStatus.initial) {
      return;
    }

    cubit.fetchAttendances(filter: _attendanceFilterFromLabel(_activeFilter));
  }

  void _fetchClassActivityIfNeeded() {
    final cubit = _classBookingHistoryCubit;

    if (cubit == null ||
        cubit.state.status != ClassBookingHistoryLoadStatus.initial) {
      return;
    }

    cubit.fetchBookings(filter: _classActivityFilter);
  }

  void _openBookingDetail(ActivityHistoryItem item) {
    final detail = item.bookingDetail;

    if (detail == null) {
      return;
    }

    Navigator.of(context).push(
      // Reuse the booking success/detail screen so PT and class QR behavior
      // stays consistent with the booking flows.
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(
          typeCode: detail.typeCode,
          itemId: detail.itemId,
          title: detail.title,
          schedule: detail.schedule,
          duration: detail.duration,
          location: detail.location,
          bookingCode: detail.bookingCode,
          qrPayload: detail.qrPayload,
        ),
      ),
    );
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
                  top: spec.isExpanded ? -148 : -104,
                  right: spec.isExpanded ? -148 : -124,
                  child: _GlowOrb(
                    size: spec.isExpanded ? 420 : 310,
                    color: AppColors.gymGold,
                    opacity: spec.isExpanded ? 0.11 : 0.13,
                  ),
                ),
                Positioned(
                  bottom: spec.isExpanded ? -160 : -116,
                  left: spec.isExpanded ? -140 : -116,
                  child: _GlowOrb(
                    size: spec.isExpanded ? 360 : 280,
                    color: AppColors.darkGold,
                    opacity: spec.isExpanded ? 0.06 : 0.08,
                  ),
                ),
                RefreshIndicator(
                  color: AppColors.gymGold,
                  backgroundColor: AppColors.graphiteBlack,
                  onRefresh: _refreshActiveTab,
                  child: CustomScrollView(
                    // Required so pull-to-refresh still works when the active
                    // tab is empty, loading, or shorter than the viewport.
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [_buildActivityContentSliver(spec)],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityContentSliver(ActivityLayoutSpec spec) {
    return SliverPadding(
      padding: spec.pagePadding,
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
              child: spec.isExpanded
                  ? _buildExpandedActivityContent(spec)
                  : _buildStackedActivityContent(spec),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStackedActivityContent(ActivityLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ActivityTopBar(),
        SizedBox(height: spec.sectionGap),
        _buildActivityHeroCard(),
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
              _buildActivityHeroCard(),
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

  Widget _buildActivityHeroCard() {
    final attendanceCubit = _memberAttendanceActivityCubit;
    final attendanceBuilder = attendanceCubit == null
        ? _buildBookingActivityHeroCard(null)
        : BlocBuilder<
            MemberAttendanceActivityCubit,
            MemberAttendanceActivityState
          >(
            bloc: attendanceCubit,
            builder: (context, attendanceState) {
              return _buildBookingActivityHeroCard(attendanceState);
            },
          );

    return attendanceBuilder;
  }

  Widget _buildBookingActivityHeroCard(
    MemberAttendanceActivityState? attendanceState,
  ) {
    // Build the summary card from whichever Cubits are available. The nested
    // builders keep each summary section reactive without introducing a new
    // aggregate Cubit for this screen.
    final personalTrainingCubit = _personalTrainingBookingHistoryCubit;
    final classCubit = _classBookingHistoryCubit;

    if (personalTrainingCubit == null && classCubit == null) {
      return ActivityHeroCard(
        stats: _buildActivitySummaryStats(attendanceState, null, null),
      );
    }

    if (personalTrainingCubit == null) {
      return BlocBuilder<ClassBookingHistoryCubit, ClassBookingHistoryState>(
        bloc: classCubit!,
        builder: (context, classState) {
          return ActivityHeroCard(
            stats: _buildActivitySummaryStats(
              attendanceState,
              null,
              classState,
            ),
          );
        },
      );
    }

    if (classCubit == null) {
      return BlocBuilder<
        PersonalTrainingBookingHistoryCubit,
        PersonalTrainingBookingHistoryState
      >(
        bloc: personalTrainingCubit,
        builder: (context, personalTrainingState) {
          return ActivityHeroCard(
            stats: _buildActivitySummaryStats(
              attendanceState,
              personalTrainingState,
              null,
            ),
          );
        },
      );
    }

    return BlocBuilder<
      PersonalTrainingBookingHistoryCubit,
      PersonalTrainingBookingHistoryState
    >(
      bloc: personalTrainingCubit,
      builder: (context, personalTrainingState) {
        return BlocBuilder<ClassBookingHistoryCubit, ClassBookingHistoryState>(
          bloc: classCubit,
          builder: (context, classState) {
            return ActivityHeroCard(
              stats: _buildActivitySummaryStats(
                attendanceState,
                personalTrainingState,
                classState,
              ),
            );
          },
        );
      },
    );
  }

  List<ActivitySummaryStat> _buildActivitySummaryStats(
    MemberAttendanceActivityState? attendanceState,
    PersonalTrainingBookingHistoryState? personalTrainingState,
    ClassBookingHistoryState? classState,
  ) {
    final attendanceCount = _formatAttendanceSummaryCount(attendanceState);
    final ptSessionCount =
        personalTrainingState == null ||
            personalTrainingState.status ==
                PersonalTrainingBookingHistoryLoadStatus.initial ||
            personalTrainingState.status ==
                PersonalTrainingBookingHistoryLoadStatus.failure
        ? '-'
        : personalTrainingState.bookings.length.toString();

    final classSessionCount =
        classState == null ||
            classState.status == ClassBookingHistoryLoadStatus.initial ||
            classState.status == ClassBookingHistoryLoadStatus.failure
        ? '-'
        : classState.bookings.length.toString();

    return [
      ActivitySummaryStat(value: attendanceCount, label: 'Kedatangan'),
      ActivitySummaryStat(value: ptSessionCount, label: 'Sesi PT'),
      ActivitySummaryStat(value: classSessionCount, label: 'Kelas'),
    ];
  }

  Widget _buildActiveTabContent(ActivityLayoutSpec spec) {
    if (_activeTab == ActivityTab.attendance) {
      return _buildAttendanceActivityContent(spec);
    }

    if (_activeTab == ActivityTab.personalTrainer) {
      return _buildPersonalTrainingActivityContent(spec);
    }

    if (_activeTab == ActivityTab.classSession) {
      return _buildClassActivityContent(spec);
    }

    return const SizedBox.shrink();
  }

  Widget _buildAttendanceActivityContent(ActivityLayoutSpec spec) {
    final cubit = _memberAttendanceActivityCubit;

    if (cubit == null) {
      return const _ActivityStatusCard.loading(
        message: 'Memuat riwayat kedatangan...',
      );
    }

    return BlocBuilder<
      MemberAttendanceActivityCubit,
      MemberAttendanceActivityState
    >(
      bloc: cubit,
      builder: (context, state) {
        // Convert API-backed attendance records into the shared activity card
        // model at the presentation boundary.
        final items = state.items
            .asMap()
            .entries
            .map(
              (entry) => mapMemberAttendanceToActivityHistoryItem(
                entry.value,
                isFeatured: entry.key == 0,
              ),
            )
            .toList(growable: false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActivityFilterChips(
              filters: _activeFilterOptions,
              activeFilter: _activeFilter,
              onFilterChanged: _changeActiveFilter,
            ),
            SizedBox(height: spec.sectionGap),
            if (state.isLoading && state.items.isEmpty)
              const _ActivityStatusCard.loading(
                message: 'Memuat riwayat kedatangan...',
              )
            else if (state.status == MemberAttendanceActivityLoadStatus.failure)
              _ActivityStatusCard.failure(
                message:
                    state.errorMessage ??
                    'Riwayat kedatangan belum bisa dimuat. Silakan coba kembali.',
                onRetryPressed: () =>
                    _memberAttendanceActivityCubit?.fetchAttendances(
                      filter: _attendanceFilterFromLabel(_activeFilter),
                      forceRefresh: true,
                    ),
              )
            else if (items.isEmpty)
              const _ActivityStatusCard.empty(
                title: 'Riwayat kedatangan masih kosong',
                message:
                    'Check-in dan check-out gym kamu akan muncul di sini setelah staff memindai barcode member.',
              )
            else ...[
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.gymGold,
                    backgroundColor: AppColors.gunmetal,
                  ),
                ),
              ActivityHistorySection(
                title: _activeTab.sectionTitle,
                countLabel: '${state.totalItems} Data',
                items: items,
                onBookingDetailPressed: _openBookingDetail,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPersonalTrainingActivityContent(ActivityLayoutSpec spec) {
    final cubit = _personalTrainingBookingHistoryCubit;

    if (cubit == null) {
      return const _ActivityStatusCard.loading(message: 'Memuat riwayat PT...');
    }

    return BlocBuilder<
      PersonalTrainingBookingHistoryCubit,
      PersonalTrainingBookingHistoryState
    >(
      bloc: cubit,
      builder: (context, state) {
        final items = _filterPersonalTrainingActivityItems(
          state.bookings
              .asMap()
              .entries
              .map(
                (entry) => mapPersonalTrainingBookingToActivityHistoryItem(
                  entry.value,
                  isFeatured: entry.key == 0,
                ),
              )
              .toList(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActivityFilterChips(
              filters: _activeFilterOptions,
              activeFilter: _activeFilter,
              onFilterChanged: _changeActiveFilter,
            ),
            SizedBox(height: spec.sectionGap),
            if (state.isLoading && state.bookings.isEmpty)
              const _ActivityStatusCard.loading(message: 'Memuat riwayat PT...')
            else if (state.status ==
                PersonalTrainingBookingHistoryLoadStatus.failure)
              _ActivityStatusCard.failure(
                message:
                    state.errorMessage ??
                    'Riwayat PT belum bisa dimuat. Silakan coba kembali.',
                onRetryPressed: () =>
                    _personalTrainingBookingHistoryCubit?.fetchBookings(
                      filter: _personalTrainingActivityFilter,
                      forceRefresh: true,
                    ),
              )
            else if (items.isEmpty)
              const _ActivityStatusCard.empty(
                title: 'Riwayat PT masih kosong',
                message:
                    'Booking personal trainer yang aktif dan sudah selesai akan muncul di sini.',
              )
            else ...[
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.gymGold,
                    backgroundColor: AppColors.gunmetal,
                  ),
                ),
              ActivityHistorySection(
                title: _activeTab.sectionTitle,
                countLabel: '${items.length} Session',
                items: items,
                onBookingDetailPressed: _openBookingDetail,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildClassActivityContent(ActivityLayoutSpec spec) {
    final cubit = _classBookingHistoryCubit;

    if (cubit == null) {
      return const _ActivityStatusCard.loading(
        message: 'Memuat riwayat kelas...',
      );
    }

    return BlocBuilder<ClassBookingHistoryCubit, ClassBookingHistoryState>(
      bloc: cubit,
      builder: (context, state) {
        final items = _filterClassActivityItems(
          state.bookings
              .asMap()
              .entries
              .map(
                (entry) => mapClassBookingToActivityHistoryItem(
                  entry.value,
                  isFeatured: entry.key == 0,
                ),
              )
              .toList(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActivityFilterChips(
              filters: _activeFilterOptions,
              activeFilter: _activeFilter,
              onFilterChanged: _changeActiveFilter,
            ),
            SizedBox(height: spec.sectionGap),
            if (state.isLoading && state.bookings.isEmpty)
              const _ActivityStatusCard.loading(
                message: 'Memuat riwayat kelas...',
              )
            else if (state.status == ClassBookingHistoryLoadStatus.failure)
              _ActivityStatusCard.failure(
                message:
                    state.errorMessage ??
                    'Riwayat kelas belum bisa dimuat. Silakan coba kembali.',
                onRetryPressed: () => _classBookingHistoryCubit?.fetchBookings(
                  filter: _classActivityFilter,
                  forceRefresh: true,
                ),
              )
            else if (items.isEmpty)
              const _ActivityStatusCard.empty(
                title: 'Riwayat kelas masih kosong',
                message:
                    'Booking kelas yang aktif dan sudah selesai akan muncul di sini.',
              )
            else ...[
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.gymGold,
                    backgroundColor: AppColors.gunmetal,
                  ),
                ),
              ActivityHistorySection(
                title: _activeTab.sectionTitle,
                countLabel: '${items.length} Kelas',
                items: items,
                onBookingDetailPressed: _openBookingDetail,
              ),
            ],
          ],
        );
      },
    );
  }

  List<ActivityHistoryItem> _filterPersonalTrainingActivityItems(
    List<ActivityHistoryItem> items,
  ) {
    // PT and class APIs are already requested with the broad "all" status set;
    // this filter only controls the visible list copy.
    if (_activeFilter == 'Selesai') {
      return items.where((item) => item.status == 'Selesai').toList();
    }

    return items;
  }

  List<ActivityHistoryItem> _filterClassActivityItems(
    List<ActivityHistoryItem> items,
  ) {
    if (_activeFilter == 'Selesai') {
      return items.where((item) => item.status == 'Selesai').toList();
    }

    return items;
  }

  MemberAttendanceHistoryFilter _attendanceFilterFromLabel(String label) {
    return switch (label) {
      'Hari Ini' => MemberAttendanceHistoryFilter.today,
      'Minggu Ini' => MemberAttendanceHistoryFilter.week,
      'Bulan Ini' => MemberAttendanceHistoryFilter.month,
      _ => MemberAttendanceHistoryFilter.all,
    };
  }

  String _formatAttendanceSummaryCount(
    MemberAttendanceActivityState? attendanceState,
  ) {
    if (attendanceState == null ||
        attendanceState.status == MemberAttendanceActivityLoadStatus.initial ||
        (attendanceState.status == MemberAttendanceActivityLoadStatus.failure &&
            attendanceState.items.isEmpty)) {
      return '-';
    }

    return attendanceState.totalItems.toString();
  }
}

class _ActivityStatusCard extends StatelessWidget {
  const _ActivityStatusCard.loading({required this.message})
    : title = 'Menyiapkan riwayat',
      onRetryPressed = null,
      icon = AppLucideIcons.history,
      showProgress = true;

  const _ActivityStatusCard.failure({
    required this.message,
    required this.onRetryPressed,
  }) : title = 'Data belum bisa dimuat',
       icon = AppLucideIcons.info,
       showProgress = false;

  const _ActivityStatusCard.empty({required this.title, required this.message})
    : onRetryPressed = null,
      icon = AppLucideIcons.userPlus,
      showProgress = false;

  final String title;
  final String message;
  final IconData icon;
  final bool showProgress;
  final VoidCallback? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final retryAction = onRetryPressed;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 216),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActivityStatusGlyph(icon: icon, showProgress: showProgress),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (retryAction != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: retryAction,
                    icon: const Icon(AppLucideIcons.history, size: 16),
                    label: const Text('Coba lagi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gymGold,
                      side: BorderSide(
                        color: AppColors.gymGold.withValues(alpha: 0.32),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityStatusGlyph extends StatelessWidget {
  const _ActivityStatusGlyph({required this.icon, required this.showProgress});

  final IconData icon;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showProgress)
            CircularProgressIndicator(
              strokeWidth: 2.4,
              strokeCap: StrokeCap.round,
              color: AppColors.gymGold,
              backgroundColor: AppColors.gymGold.withValues(alpha: 0.10),
              semanticsLabel: 'Memuat riwayat aktivitas',
            ),
          Icon(icon, color: AppColors.gymGold, size: 22),
        ],
      ),
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
    // Breakpoints follow the project responsive guideline:
    // mobile < 600, tablet 600-839, expanded >= 840.
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
      child: RepaintBoundary(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.34),
                color.withValues(alpha: 0),
              ],
              stops: const [0, 0.46, 1],
            ),
          ),
        ),
      ),
    );
  }
}
