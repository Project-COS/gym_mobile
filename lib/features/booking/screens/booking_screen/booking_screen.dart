import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../../data/booking_data.dart';
import '../../data/repositories/booking_class_repository.dart';
import '../../../lokasi/data/repositories/location_repository.dart';
import '../../../lokasi/screen/branch_location_data.dart';
import '../detail_class_screen/detail_class_screen.dart';
import '../detail_personal_trainer_screen/detail_personal_trainer_screen.dart';
import 'widget/booking_category_filter.dart';
import 'widget/booking_date_strip.dart';
import 'widget/booking_empty_state.dart';
import 'widget/booking_hero_card.dart';
import 'widget/booking_session_card.dart';
import 'widget/booking_tab_selector.dart';
import 'widget/booking_top_bar.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  BookingTab _activeTab = BookingTab.personalTrainer;
  ClassCategory _activeCategory = ClassCategory.all;
  int _selectedPersonalTrainerDateIndex = 0;
  int _selectedClassDateIndex = 0;
  final List<BookingDateOption> _dateOptions =
      buildUpcomingBookingDateOptions();
  List<GroupClassSession> _classSessions = const [];
  List<BranchLocation>? _classLocations;
  BookingClassLoadStatus _classLoadStatus = BookingClassLoadStatus.initial;
  String? _classErrorMessage;
  String? _classLocationName;

  List<GroupClassSession> get _visibleClasses {
    return _classSessions.where((session) {
      return _activeCategory == ClassCategory.all ||
          session.category == _activeCategory;
    }).toList();
  }

  void _changeActiveTab(BookingTab tab) {
    setState(() {
      _activeTab = tab;
    });

    if (tab == BookingTab.classSession &&
        _classLoadStatus == BookingClassLoadStatus.initial) {
      _fetchClassesForSelectedDate();
    }
  }

  void _changeSelectedPersonalTrainerDateIndex(int index) {
    setState(() {
      _selectedPersonalTrainerDateIndex = index;
    });
  }

  void _changeSelectedClassDateIndex(int index) {
    setState(() {
      _selectedClassDateIndex = index;
    });
    _fetchClassesForSelectedDate();
  }

  void _changeActiveCategory(ClassCategory category) {
    setState(() {
      _activeCategory = category;
    });
  }

  void _openPersonalTrainerDetail(PersonalTrainerSession session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailPersonalTrainerScreen(session: session),
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

  void _showBookingToast(String name) {
    _showMessage('$name berhasil dibooking.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _fetchClassesForSelectedDate() async {
    setState(() {
      _classLoadStatus = BookingClassLoadStatus.loading;
      _classErrorMessage = null;
    });

    final LocationRepository locationRepository = context
        .read<LocationRepository>();
    final BookingClassRepository bookingClassRepository = context
        .read<BookingClassRepository>();

    try {
      final List<BranchLocation> locations =
          _classLocations ?? await locationRepository.fetchLocations();
      _classLocations = locations;

      if (locations.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _classSessions = const [];
          _classLocationName = null;
          _classLoadStatus = BookingClassLoadStatus.success;
        });
        return;
      }

      final BranchLocation selectedLocation = locations.first;
      final DateTime selectedDate = _dateOptions[_selectedClassDateIndex].date;
      final DateTime startsFrom = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final DateTime startsTo = startsFrom.add(const Duration(days: 1));
      final List<GroupClassSession> classes = await bookingClassRepository
          .fetchClassesForLocation(
            locationId: selectedLocation.id,
            startsFrom: startsFrom,
            startsTo: startsTo,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _classSessions = classes;
        _classLocationName = selectedLocation.name;
        _classLoadStatus = BookingClassLoadStatus.success;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _classSessions = const [];
        _classLoadStatus = BookingClassLoadStatus.failure;
        _classErrorMessage = 'Kelas belum bisa dimuat. Silakan coba kembali.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blackCore,
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
                          ? _buildExpandedBookingContent(spec)
                          : _buildStackedBookingContent(spec),
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

  Widget _buildStackedBookingContent(BookingLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BookingTopBar(),
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
              const BookingTopBar(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookingDateStrip(
          title: 'Pilih Tanggal PT',
          dates: _dateOptions,
          selectedIndex: _selectedPersonalTrainerDateIndex,
          onDateSelected: _changeSelectedPersonalTrainerDateIndex,
        ),
        SizedBox(height: spec.sectionGap),
        _SectionHeader(
          title: 'Personal Trainer',
          countLabel: '${personalTrainerSessions.length} Trainer',
        ),
        const SizedBox(height: 14),
        _BookingList(
          children: personalTrainerSessions.map((session) {
            return PersonalTrainerBookingCard(
              session: session,
              onDetailPressed: () => _openPersonalTrainerDetail(session),
              onBookingPressed: () => _showBookingToast(
                'PT Session ${session.name.replaceFirst('Coach ', '')}',
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClassContent(BookingLayoutSpec spec) {
    final List<GroupClassSession> visibleClasses = _visibleClasses;

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
        BookingCategoryFilter(
          activeCategory: _activeCategory,
          onCategoryChanged: _changeActiveCategory,
        ),
        SizedBox(height: spec.sectionGap),
        _SectionHeader(
          title: _classLocationName == null
              ? 'Kelas Tersedia'
              : 'Kelas di $_classLocationName',
          countLabel: '${visibleClasses.length} Kelas',
        ),
        const SizedBox(height: 14),
        _buildClassResult(visibleClasses),
      ],
    );
  }

  Widget _buildClassResult(List<GroupClassSession> visibleClasses) {
    if (_classLoadStatus == BookingClassLoadStatus.loading ||
        _classLoadStatus == BookingClassLoadStatus.initial) {
      return const _BookingStatusCard.loading();
    }

    if (_classLoadStatus == BookingClassLoadStatus.failure) {
      return _BookingStatusCard.failure(
        message:
            _classErrorMessage ??
            'Kelas belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: _fetchClassesForSelectedDate,
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
          onBookingPressed: () => _showBookingToast(session.title),
        );
      }).toList(),
    );
  }
}

enum BookingClassLoadStatus { initial, loading, success, failure }

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
