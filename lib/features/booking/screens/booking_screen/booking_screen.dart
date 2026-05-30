import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/booking_data.dart';
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

  List<GroupClassSession> get _visibleClasses {
    return groupClassSessions.where((session) {
      return _activeCategory == ClassCategory.all ||
          session.category == _activeCategory;
    }).toList();
  }

  void _changeActiveTab(BookingTab tab) {
    setState(() {
      _activeTab = tab;
    });
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
          title: 'Kelas Tersedia',
          countLabel: '${visibleClasses.length} Kelas',
        ),
        const SizedBox(height: 14),
        if (visibleClasses.isEmpty)
          const BookingEmptyState()
        else
          _BookingList(
            children: visibleClasses.map((session) {
              return GroupClassBookingCard(
                session: session,
                onDetailPressed: () => _openClassDetail(session),
                onBookingPressed: () => _showBookingToast(session.title),
              );
            }).toList(),
          ),
      ],
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
