import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/colors.dart';
import '../../../core/icons/app_lucide_icons.dart';
import '../../activity/screens/activity_screen.dart';
import '../../booking/screens/booking_screen/booking_screen.dart';
import '../../lokasi/screen/lokasi_cabang_screen.dart';
import '../../member_attendance/data/repositories/member_attendance_repository.dart';
import '../../member_attendance/presentation/cubit/member_attendance_qr_cubit.dart';
import '../../member_attendance/presentation/widgets/member_attendance_qr_sheet.dart';
import '../../profile/presentation/screens/profile_screen.dart';
import 'widget/home_bottom_navigation_bar.dart';
import 'widget/home_navigation_rail.dart';
import 'widget/home_top_bar.dart';
import 'widget/membership_card.dart';
import 'widget/membership_renewal_card.dart';
import 'widget/upcoming_schedule_section.dart';
import 'widget/weekly_activity_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> _labels = const [
    'Home',
    'Lokasi',
    'Booking',
    'Activity',
    'Profile',
  ];

  final List<IconData> _icons = const [
    AppLucideIcons.home,
    AppLucideIcons.mapPin,
    AppLucideIcons.calendar,
    AppLucideIcons.chart,
    AppLucideIcons.person,
  ];

  void _changeSelectedNavigationIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _buildPages() {
    return [
      const HomeScreenContent(),
      const LokasiCabangScreen(),
      const BookingScreen(),
      ActivityScreen(isActive: _selectedIndex == 3),
      ProfileScreen(isActive: _selectedIndex == 4),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final Widget pages = IndexedStack(
          index: _selectedIndex,
          children: _buildPages(),
        );

        if (isMobile) {
          return Scaffold(
            backgroundColor: AppColors.blackCore,
            body: pages,
            bottomNavigationBar: HomeBottomNavigationBar(
              labels: _labels,
              icons: _icons,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _changeSelectedNavigationIndex,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.blackCore,
          body: SafeArea(
            child: Row(
              children: [
                HomeNavigationRail(
                  labels: _labels,
                  icons: _icons,
                  selectedIndex: _selectedIndex,
                  isExtended: constraints.maxWidth >= 840,
                  onDestinationSelected: _changeSelectedNavigationIndex,
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.gunmetal,
                ),
                Expanded(child: pages),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  void _openMemberAttendanceQr() {
    final repository = context.read<MemberAttendanceRepository>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.graphiteBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return BlocProvider(
          create: (_) =>
              MemberAttendanceQrCubit(repository: repository)..createQr(),
          child: const MemberAttendanceQrSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blackCore,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final HomeLayoutSpec spec = HomeLayoutSpec.fromWidth(
              constraints.maxWidth,
            );

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: spec.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
                  child: spec.isExpanded
                      ? _buildExpandedContent(spec)
                      : _buildStackedContent(spec),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStackedContent(HomeLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeTopBar(),
        SizedBox(height: spec.sectionGap),
        MembershipCard(onShowQr: _openMemberAttendanceQr),
        SizedBox(height: spec.sectionGap),
        const WeeklyActivitySection(),
        SizedBox(height: spec.sectionGap),
        const UpcomingScheduleSection(),
        SizedBox(height: spec.sectionGap),
        const MembershipRenewalCard(),
      ],
    );
  }

  Widget _buildExpandedContent(HomeLayoutSpec spec) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeTopBar(),
              SizedBox(height: spec.sectionGap),
              MembershipCard(onShowQr: _openMemberAttendanceQr),
              SizedBox(height: spec.sectionGap),
              const UpcomingScheduleSection(),
            ],
          ),
        ),
        SizedBox(width: spec.columnGap),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WeeklyActivitySection(),
              SizedBox(height: spec.sectionGap),
              const MembershipRenewalCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeLayoutSpec {
  const HomeLayoutSpec({
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

  factory HomeLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const HomeLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const HomeLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const HomeLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 18,
      columnGap: 0,
    );
  }
}

class CenterPage extends StatefulWidget {
  final String title;

  const CenterPage({super.key, required this.title});

  @override
  State<CenterPage> createState() => _CenterPageState();
}

class _CenterPageState extends State<CenterPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blackCore,
      alignment: Alignment.center,
      child: Text(
        widget.title,
        style: const TextStyle(
          color: AppColors.metallicWhite,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
