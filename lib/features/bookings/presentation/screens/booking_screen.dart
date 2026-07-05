import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
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
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextClassDateRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    _activeCategoryId = null;
  }

  @override
  Widget build(BuildContext context) {
    final trainerListCubit = _trainerListCubit;
    final bookingClassCubit = _bookingClassCubit;

    if (trainerListCubit == null || bookingClassCubit == null) {
      return const ColoredBox(
        color: AppColors.blackCore,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.gymGold),
        ),
      );
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
                  RefreshIndicator(
                    color: AppColors.gymGold,
                    backgroundColor: AppColors.graphiteBlack,
                    onRefresh: _refreshActiveTab,
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
                              ? _buildExpandedBookingContent(spec)
                              : _buildStackedBookingContent(spec),
                        ),
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

  Widget _buildStackedBookingContent(BookingLayoutSpec spec) {
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
        SizedBox(height: spec.sectionGap),
        _buildActiveTabContent(spec),
      ],
    );
  }

  Widget _buildExpandedBookingContent(BookingLayoutSpec spec) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingHeader(
                onHistoryPressed: _openPersonalTrainingBookingHistory,
              ),
              SizedBox(height: spec.sectionGap),
              const BookingHeroCard(),
              SizedBox(height: spec.sectionGap),
              BookingTabSelector(
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

  Widget _buildActiveTabContent(BookingLayoutSpec spec) {
    return switch (_activeTab) {
      BookingTab.personalTrainer => _buildPersonalTrainerContent(spec),
      BookingTab.classSession => _buildClassContent(spec),
    };
  }

  Widget _buildPersonalTrainerContent(BookingLayoutSpec spec) {
    return BlocBuilder<TrainerListCubit, TrainerListState>(
      builder: (context, state) {
        final trainers = state.trainers;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrainerCatalogHeader(count: trainers.length),
            const SizedBox(height: 14),
            _buildTrainerResult(state),
          ],
        );
      },
    );
  }

  Widget _buildTrainerResult(TrainerListState state) {
    if (state.status == TrainerListLoadStatus.loading &&
        state.trainers.isEmpty) {
      return const TrainerStatusCard.loading();
    }

    if (state.status == TrainerListLoadStatus.failure &&
        state.trainers.isEmpty) {
      return TrainerStatusCard.failure(
        message:
            state.errorMessage ??
            'Trainer belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: () =>
            _trainerListCubit?.fetchTrainers(forceRefresh: true),
      );
    }

    if (state.trainers.isEmpty) {
      return const TrainerStatusCard.empty();
    }

    return _BookingList(
      children: state.trainers.map((trainer) {
        return TrainerProfileCard(
          trainer: trainer,
          onDetailPressed: () => _openTrainerDetail(trainer),
        );
      }).toList(),
    );
  }

  Widget _buildClassContent(BookingLayoutSpec spec) {
    return BlocBuilder<BookingClassCubit, BookingClassState>(
      builder: (context, state) {
        final List<GroupClassSession> visibleClasses = _visibleClasses(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingDateStrip(
              title: 'Pilih Tanggal Kelas',
              dates: _dateOptions,
              selectedIndex: _selectedClassDateIndex,
              onDateSelected: _changeSelectedClassDateIndex,
            ),
            SizedBox(height: spec.sectionGap),
            ClassCategoryFilter(
              categories: state.categories,
              activeCategoryId: _activeCategoryId,
              onCategoryChanged: _changeActiveCategory,
            ),
            SizedBox(height: spec.sectionGap),
            _SectionHeader(
              title: state.locationName == null
                  ? 'Kelas Semua Cabang'
                  : 'Kelas di ${state.locationName}',
              countLabel: '${visibleClasses.length} Kelas',
            ),
            const SizedBox(height: 14),
            _buildClassResult(state, visibleClasses),
          ],
        );
      },
    );
  }

  Widget _buildClassResult(
    BookingClassState state,
    List<GroupClassSession> visibleClasses,
  ) {
    if (state.status == BookingClassLoadStatus.loading ||
        state.status == BookingClassLoadStatus.initial) {
      return const _BookingStatusCard.loading();
    }

    if (state.status == BookingClassLoadStatus.failure) {
      return _BookingStatusCard.failure(
        message:
            state.errorMessage ??
            'Kelas belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: () => _fetchClassesForSelectedDate(forceRefresh: true),
      );
    }

    if (visibleClasses.isEmpty) {
      return const BookingEmptyState();
    }

    return _BookingList(
      children: visibleClasses.map((session) {
        return GroupClassBookingCard(
          session: session,
          onDetailPressed: () => _openClassDetail(session),
          onBookingPressed: () => _openClassDetail(session),
        );
      }).toList(),
    );
  }
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader({required this.onHistoryPressed});

  final VoidCallback onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: BookingTopBar()),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onHistoryPressed,
          icon: const Icon(Icons.history_rounded, size: 16),
          label: const Text('History PT'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gymGold,
            side: BorderSide(color: AppColors.gymGold.withValues(alpha: 0.44)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
  const _BookingStatusCard.loading()
    : message = 'Memuat kelas tersedia...',
      onRetryPressed = null;

  const _BookingStatusCard.failure({
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

class _BookingList extends StatelessWidget {
  const _BookingList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == children.length - 1 ? 0 : 14,
          ),
          child: children[index],
        );
      }),
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
