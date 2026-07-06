import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/booking_data.dart';
import 'personal_training_booking_history_screen.dart';
import '../../../classes/data/class_data.dart';
import '../../../classes/data/repositories/booking_class_repository.dart';
import '../../../classes/presentation/cubit/booking_class_cubit.dart';
import '../../../classes/presentation/screens/detail_class_screen.dart';
import '../../../classes/presentation/widgets/class_category_filter.dart';
import '../../../classes/presentation/widgets/group_class_booking_card.dart';
import '../../../trainers/data/repositories/trainer_repository.dart';
import '../../../trainers/presentation/cubit/trainer_list_cubit.dart';
import '../../../trainers/presentation/screens/trainer_detail_screen.dart';
import '../../../trainers/presentation/widgets/trainer_catalog_widgets.dart';
import '../widgets/booking_screen/booking_date_strip.dart';
import '../widgets/booking_screen/booking_empty_state.dart';
import '../widgets/booking_screen/booking_hero_card.dart';
import '../widgets/booking_screen/booking_tab_selector.dart';
import '../widgets/booking_screen/booking_top_bar.dart';

// Main booking surface. It composes PT trainer discovery from the trainers
// feature and class session discovery from the classes feature.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with WidgetsBindingObserver {
  BookingTab _activeTab = BookingTab.personalTrainer;
  String? _activeCategoryId;
  int _selectedClassDateIndex = 0;
  List<BookingDateOption> _dateOptions = buildUpcomingBookingDateOptions();
  DateTime _dateOptionsBaseDate = normalizeBookingCalendarDate(DateTime.now());
  Timer? _classDateRefreshTimer;
  TrainerRepository? _trainerRepository;
  TrainerListCubit? _trainerListCubit;
  BookingClassRepository? _bookingClassRepository;
  BookingClassCubit? _bookingClassCubit;

  List<GroupClassSession> _visibleClasses(BookingClassState state) {
    return state.sessions.where((session) {
      return _activeCategoryId == null ||
          session.categoryId == _activeCategoryId;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Observe app resume so the class date strip can roll forward after the app
    // has been backgrounded overnight.
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextClassDateRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recreate local Cubits only when their injected repositories change.
    final trainerRepository = context.read<TrainerRepository>();
    final bookingClassRepository = context.read<BookingClassRepository>();

    if (_trainerRepository != trainerRepository || _trainerListCubit == null) {
      _trainerListCubit?.close();
      _trainerRepository = trainerRepository;
      _trainerListCubit = TrainerListCubit(repository: trainerRepository)
        ..fetchTrainers();
    }

    if (_bookingClassRepository != bookingClassRepository ||
        _bookingClassCubit == null) {
      _bookingClassCubit?.close();
      _bookingClassRepository = bookingClassRepository;
      _bookingClassCubit = BookingClassCubit(
        bookingClassRepository: bookingClassRepository,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _classDateRefreshTimer?.cancel();
    _trainerListCubit?.close();
    _bookingClassCubit?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    final bool dateOptionsChanged = _refreshClassDateOptionsIfNeeded();
    _scheduleNextClassDateRefresh();

    // If the date strip moved to a new day while paused, refresh the currently
    // visible class results to match the new selected date.
    if (dateOptionsChanged && _activeTab == BookingTab.classSession) {
      _fetchClassesForSelectedDate(forceRefresh: true);
    }
  }

  void _changeActiveTab(BookingTab tab) {
    final bool shouldRefreshClassDates =
        tab == BookingTab.classSession && _classDateOptionsNeedRefresh();

    setState(() {
      _activeTab = tab;

      if (shouldRefreshClassDates) {
        _refreshClassDateOptionsForToday();
      }
    });

    if (tab == BookingTab.classSession &&
        (_bookingClassCubit?.state.status == BookingClassLoadStatus.initial ||
            shouldRefreshClassDates)) {
      // Class data is loaded lazily because the default booking tab shows PT.
      _fetchClassesForSelectedDate(forceRefresh: shouldRefreshClassDates);
    }
  }

  void _changeSelectedClassDateIndex(int index) {
    setState(() {
      _selectedClassDateIndex = index;
      _activeCategoryId = null;
    });
    _fetchClassesForSelectedDate();
  }

  void _changeActiveCategory(String? categoryId) {
    setState(() {
      _activeCategoryId = categoryId;
    });
  }

  void _openTrainerDetail(TrainerProfile trainer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrainerDetailScreen(trainerId: trainer.id),
      ),
    );
  }

  void _openClassDetail(GroupClassSession session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailClassScreen(session: session),
      ),
    );
  }

  void _openPersonalTrainingBookingHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PersonalTrainingBookingHistoryScreen(),
      ),
    );
  }

  Future<void> _refreshActiveTab() {
    // RefreshIndicator expects this Future to complete after the active tab has
    // finished reloading.
    if (_activeTab == BookingTab.personalTrainer) {
      return _trainerListCubit?.fetchTrainers(forceRefresh: true) ??
          Future<void>.value();
    }

    _refreshClassDateOptionsIfNeeded();
    return _fetchClassesForSelectedDate(forceRefresh: true);
  }

  Future<void> _fetchClassesForSelectedDate({bool forceRefresh = false}) {
    return _bookingClassCubit?.fetchClassesForDate(
          _dateOptions[_selectedClassDateIndex].date,
          forceRefresh: forceRefresh,
        ) ??
        Future<void>.value();
  }

  void _scheduleNextClassDateRefresh() {
    _classDateRefreshTimer?.cancel();

    final now = DateTime.now();
    final nextCalendarDay = normalizeBookingCalendarDate(
      now,
    ).add(const Duration(days: 1));

    // Keep the in-memory date strip correct even when the booking screen stays
    // mounted past midnight.
    _classDateRefreshTimer = Timer(
      nextCalendarDay.difference(now),
      _refreshClassDateOptionsAfterMidnight,
    );
  }

  void _refreshClassDateOptionsAfterMidnight() {
    if (!mounted) {
      return;
    }

    final bool dateOptionsChanged = _refreshClassDateOptionsIfNeeded();
    _scheduleNextClassDateRefresh();

    if (dateOptionsChanged && _activeTab == BookingTab.classSession) {
      _fetchClassesForSelectedDate(forceRefresh: true);
    }
  }

  bool _refreshClassDateOptionsIfNeeded() {
    if (!_classDateOptionsNeedRefresh()) {
      return false;
    }

    setState(_refreshClassDateOptionsForToday);
    return true;
  }

  bool _classDateOptionsNeedRefresh() {
    return !isSameBookingCalendarDate(_dateOptionsBaseDate, DateTime.now());
  }

  void _refreshClassDateOptionsForToday() {
    final previouslySelectedDate = _dateOptions[_selectedClassDateIndex].date;
    final today = normalizeBookingCalendarDate(DateTime.now());
    final nextDateOptions = buildUpcomingBookingDateOptions(today: today);

    _dateOptions = nextDateOptions;
    _dateOptionsBaseDate = today;
    _selectedClassDateIndex = findBookingDateOptionIndexForDate(
      nextDateOptions,
      previouslySelectedDate,
    );
    // Categories are tied to loaded class data, so clear them after the date
    // window changes.
    _activeCategoryId = null;
  }

  @override
  Widget build(BuildContext context) {
    final trainerListCubit = _trainerListCubit;
    final bookingClassCubit = _bookingClassCubit;

    if (trainerListCubit == null || bookingClassCubit == null) {
      return const _BookingBootLoadingScreen();
    }

    return Container(
      color: AppColors.blackCore,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TrainerListCubit>.value(value: trainerListCubit),
          BlocProvider<BookingClassCubit>.value(value: bookingClassCubit),
        ],
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final BookingLayoutSpec spec = BookingLayoutSpec.fromWidth(
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
                      // Required so pull-to-refresh still works for empty or
                      // short booking lists.
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: _buildBookingSlivers(spec),
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

  List<Widget> _buildBookingSlivers(BookingLayoutSpec spec) {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          spec.pagePadding.left,
          spec.pagePadding.top,
          spec.pagePadding.right,
          0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            _CenteredBookingContent(
              spec: spec,
              child: _buildBookingIntro(spec),
            ),
            SizedBox(height: spec.sectionGap),
          ]),
        ),
      ),
      _buildActiveTabContent(spec),
      SliverToBoxAdapter(child: SizedBox(height: spec.pagePadding.bottom)),
    ];
  }

  Widget _buildBookingIntro(BookingLayoutSpec spec) {
    return spec.isExpanded
        ? _buildExpandedBookingIntro(spec)
        : _buildStackedBookingIntro(spec);
  }

  Widget _buildStackedBookingIntro(BookingLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookingHeader(onHistoryPressed: _openPersonalTrainingBookingHistory),
        SizedBox(height: spec.sectionGap),
        const BookingHeroCard(),
        SizedBox(height: spec.sectionGap),
        BookingTabSelector(
          activeTab: _activeTab,
          onTabChanged: _changeActiveTab,
        ),
      ],
    );
  }

  Widget _buildExpandedBookingIntro(BookingLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookingHeader(onHistoryPressed: _openPersonalTrainingBookingHistory),
        SizedBox(height: spec.sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 7, child: BookingHeroCard()),
            SizedBox(width: spec.columnGap),
            Expanded(
              flex: 4,
              child: BookingTabSelector(
                activeTab: _activeTab,
                onTabChanged: _changeActiveTab,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(BookingLayoutSpec spec) {
    return switch (_activeTab) {
      BookingTab.personalTrainer => _buildPersonalTrainerContent(spec),
      BookingTab.classSession => _buildClassContent(spec),
    };
  }

  Widget _buildPersonalTrainerContent(BookingLayoutSpec spec) {
    return SliverPadding(
      padding: _horizontalPagePadding(spec.pagePadding),
      sliver: BlocBuilder<TrainerListCubit, TrainerListState>(
        builder: (context, state) {
          final trainers = state.trainers;
          final Widget header = TrainerCatalogHeader(count: trainers.length);
          final Widget? statusCard = _buildTrainerStatusCard(state);

          if (statusCard != null) {
            return SliverList(
              delegate: SliverChildListDelegate.fixed([
                _centeredSliverChild(spec, header, bottom: 14),
                _centeredSliverChild(spec, statusCard),
              ]),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                return _centeredSliverChild(spec, header, bottom: 14);
              }

              final int trainerIndex = index - 1;
              final TrainerProfile trainer = trainers[trainerIndex];

              return _centeredSliverChild(
                spec,
                TrainerProfileCard(
                  trainer: trainer,
                  onDetailPressed: () => _openTrainerDetail(trainer),
                ),
                bottom: trainerIndex == trainers.length - 1 ? 0 : 14,
              );
            }, childCount: trainers.length + 1),
          );
        },
      ),
    );
  }

  Widget? _buildTrainerStatusCard(TrainerListState state) {
    if (state.status == TrainerListLoadStatus.loading &&
        state.trainers.isEmpty) {
      return const _BookingStatusCard.loading(
        title: 'Menyiapkan trainer',
        message: 'Mengambil trainer dan slot personal training.',
        icon: AppLucideIcons.userPlus,
      );
    }

    if (state.status == TrainerListLoadStatus.failure &&
        state.trainers.isEmpty) {
      return _BookingStatusCard.failure(
        title: 'Trainer belum bisa dimuat',
        message:
            state.errorMessage ??
            'Trainer belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: () =>
            _trainerListCubit?.fetchTrainers(forceRefresh: true),
      );
    }

    if (state.trainers.isEmpty) {
      return const _BookingStatusCard.empty(
        title: 'Trainer belum tersedia',
        message: 'Belum ada trainer aktif yang bisa dibooking saat ini.',
        icon: AppLucideIcons.userPlus,
      );
    }

    return null;
  }

  Widget _buildClassContent(BookingLayoutSpec spec) {
    return SliverPadding(
      padding: _horizontalPagePadding(spec.pagePadding),
      sliver: BlocBuilder<BookingClassCubit, BookingClassState>(
        builder: (context, state) {
          // Category filtering is local to the selected date result.
          final List<GroupClassSession> visibleClasses = _visibleClasses(state);
          final Widget? statusCard = _buildClassStatusCard(
            state,
            visibleClasses,
          );

          if (statusCard != null) {
            return SliverList(
              delegate: SliverChildListDelegate.fixed([
                _centeredSliverChild(
                  spec,
                  BookingDateStrip(
                    title: 'Pilih tanggal kelas',
                    dates: _dateOptions,
                    selectedIndex: _selectedClassDateIndex,
                    onDateSelected: _changeSelectedClassDateIndex,
                  ),
                  bottom: spec.sectionGap,
                ),
                _centeredSliverChild(
                  spec,
                  ClassCategoryFilter(
                    categories: state.categories,
                    activeCategoryId: _activeCategoryId,
                    onCategoryChanged: _changeActiveCategory,
                  ),
                  bottom: spec.sectionGap,
                ),
                _centeredSliverChild(
                  spec,
                  _SectionHeader(
                    title: state.locationName == null
                        ? 'Kelas semua cabang'
                        : 'Kelas di ${state.locationName}',
                    countLabel: '${visibleClasses.length} kelas',
                  ),
                  bottom: 14,
                ),
                _centeredSliverChild(spec, statusCard),
              ]),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                return _centeredSliverChild(
                  spec,
                  BookingDateStrip(
                    title: 'Pilih tanggal kelas',
                    dates: _dateOptions,
                    selectedIndex: _selectedClassDateIndex,
                    onDateSelected: _changeSelectedClassDateIndex,
                  ),
                  bottom: spec.sectionGap,
                );
              }

              if (index == 1) {
                return _centeredSliverChild(
                  spec,
                  ClassCategoryFilter(
                    categories: state.categories,
                    activeCategoryId: _activeCategoryId,
                    onCategoryChanged: _changeActiveCategory,
                  ),
                  bottom: spec.sectionGap,
                );
              }

              if (index == 2) {
                return _centeredSliverChild(
                  spec,
                  _SectionHeader(
                    title: state.locationName == null
                        ? 'Kelas semua cabang'
                        : 'Kelas di ${state.locationName}',
                    countLabel: '${visibleClasses.length} kelas',
                  ),
                  bottom: 14,
                );
              }

              final int sessionIndex = index - 3;
              final GroupClassSession session = visibleClasses[sessionIndex];

              return _centeredSliverChild(
                spec,
                GroupClassBookingCard(
                  session: session,
                  onDetailPressed: () => _openClassDetail(session),
                  onBookingPressed: () => _openClassDetail(session),
                ),
                bottom: sessionIndex == visibleClasses.length - 1 ? 0 : 14,
              );
            }, childCount: visibleClasses.length + 3),
          );
        },
      ),
    );
  }

  Widget? _buildClassStatusCard(
    BookingClassState state,
    List<GroupClassSession> visibleClasses,
  ) {
    if (state.status == BookingClassLoadStatus.loading ||
        state.status == BookingClassLoadStatus.initial) {
      return const _BookingStatusCard.loading(
        title: 'Menyiapkan kelas',
        message: 'Mengambil kelas tersedia untuk tanggal pilihan.',
        icon: AppLucideIcons.calendarClock,
      );
    }

    if (state.status == BookingClassLoadStatus.failure) {
      return _BookingStatusCard.failure(
        title: 'Kelas belum bisa dimuat',
        message:
            state.errorMessage ??
            'Kelas belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: () => _fetchClassesForSelectedDate(forceRefresh: true),
      );
    }

    if (visibleClasses.isEmpty) {
      return const BookingEmptyState();
    }

    return null;
  }

  EdgeInsets _horizontalPagePadding(EdgeInsets padding) {
    return EdgeInsets.fromLTRB(padding.left, 0, padding.right, 0);
  }

  Widget _centeredSliverChild(
    BookingLayoutSpec spec,
    Widget child, {
    double bottom = 0,
  }) {
    return _CenteredBookingContent(
      spec: spec,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: child,
      ),
    );
  }
}

class _BookingBootLoadingScreen extends StatelessWidget {
  const _BookingBootLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.blackCore,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -104,
              right: -124,
              child: _GlowOrb(
                size: 310,
                color: AppColors.gymGold,
                opacity: 0.13,
              ),
            ),
            Positioned(
              bottom: -116,
              left: -116,
              child: _GlowOrb(
                size: 280,
                color: AppColors.darkGold,
                opacity: 0.08,
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 420),
                  child: _BookingStatusCard.loading(
                    title: 'Menyiapkan booking',
                    message: 'Menyusun data trainer dan kelas latihan.',
                    icon: AppLucideIcons.calendarClock,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader({required this.onHistoryPressed});

  final VoidCallback onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 390;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: BookingTopBar()),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: onHistoryPressed,
          icon: const Icon(AppLucideIcons.history, size: 16),
          label: Text(compact ? 'Riwayat' : 'Riwayat PT'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gymGold,
            side: BorderSide(color: AppColors.gymGold.withValues(alpha: 0.28)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingStatusCard extends StatelessWidget {
  const _BookingStatusCard.loading({
    required this.title,
    required this.message,
    required this.icon,
  }) : isLoading = true,
       onRetryPressed = null;

  const _BookingStatusCard.failure({
    required this.title,
    required this.message,
    required this.onRetryPressed,
  }) : icon = AppLucideIcons.info,
       isLoading = false;

  const _BookingStatusCard.empty({
    required this.title,
    required this.message,
    required this.icon,
  }) : isLoading = false,
       onRetryPressed = null;

  final String title;
  final String message;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? retryAction = onRetryPressed;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.all(16),
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
              _BookingStatusGlyph(isLoading: isLoading, icon: icon),
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

class _BookingStatusGlyph extends StatelessWidget {
  const _BookingStatusGlyph({required this.isLoading, required this.icon});

  final bool isLoading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isLoading)
            CircularProgressIndicator(
              strokeWidth: 2.4,
              strokeCap: StrokeCap.round,
              color: AppColors.gymGold,
              backgroundColor: AppColors.gymGold.withValues(alpha: 0.10),
              semanticsLabel: 'Memuat data booking',
            ),
          Icon(icon, color: AppColors.gymGold, size: 21),
        ],
      ),
    );
  }
}

class _CenteredBookingContent extends StatelessWidget {
  const _CenteredBookingContent({required this.spec, required this.child});

  final BookingLayoutSpec spec;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
        child: child,
      ),
    );
  }
}

class BookingLayoutSpec {
  const BookingLayoutSpec({
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

  factory BookingLayoutSpec.fromWidth(double width) {
    // Breakpoints follow the project responsive guideline:
    // mobile < 600, tablet 600-839, expanded >= 840.
    if (width >= 840) {
      return const BookingLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const BookingLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const BookingLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 18,
      columnGap: 0,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.countLabel});

  final String title;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.gymGold.withValues(alpha: 0.18),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            countLabel,
            style: const TextStyle(
              color: AppColors.gymGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
