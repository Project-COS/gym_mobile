import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../../data/booking_data.dart';
import '../booking_success_screen/booking_success_screen.dart';
import 'widget/detail_class_widgets.dart';

class DetailClassScreen extends StatefulWidget {
  const DetailClassScreen({super.key, required this.session});

  final GroupClassSession session;

  @override
  State<DetailClassScreen> createState() => _DetailClassScreenState();
}

class _DetailClassScreenState extends State<DetailClassScreen> {
  int _selectedSlotIndex = 0;
  bool _isConfirmationOpen = false;

  GroupClassSession get _session => widget.session;

  BookingSlot get _selectedSlot => _session.slots[_selectedSlotIndex];

  void _changeSelectedSlotIndex(int index) {
    setState(() {
      _selectedSlotIndex = index;
    });
  }

  void _resetSelectedSlot() {
    setState(() {
      _selectedSlotIndex = 0;
    });
  }

  void _openConfirmationSheet() {
    setState(() {
      _isConfirmationOpen = true;
    });
  }

  void _closeConfirmationSheet() {
    setState(() {
      _isConfirmationOpen = false;
    });
  }

  Future<void> _openMaps() async {
    final Uri mapsUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': _session.mapQuery,
    });

    await _launchExternalUri(
      mapsUri,
      fallbackMessage: 'Maps belum bisa dibuka dari perangkat ini.',
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

  Future<void> _shareClass() async {
    final String shareText =
        '${_session.title} - ${_selectedSlot.label} di ${_session.branch}';

    await Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      _showMessage('Link berhasil disalin.');
    }
  }

  void _confirmBooking() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(
          typeCode: 'class',
          itemId: _session.id,
          title: _session.title,
          schedule: _selectedSlot.label,
          duration: _session.duration,
          location: _session.location,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackCore,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final DetailClassLayoutSpec spec = DetailClassLayoutSpec.fromWidth(
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
                          ? _buildExpandedContent(spec)
                          : _buildStackedContent(spec),
                    ),
                  ),
                ),
                if (_isConfirmationOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _closeConfirmationSheet,
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.58),
                      ),
                    ),
                  ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  left: 0,
                  right: 0,
                  bottom: _isConfirmationOpen ? 0 : -520,
                  child: ClassBookingSheet(
                    session: _session,
                    selectedSlot: _selectedSlot,
                    onCancelPressed: _closeConfirmationSheet,
                    onConfirmPressed: _confirmBooking,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStackedContent(DetailClassLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClassDetailTopBar(
          onBackPressed: () => Navigator.of(context).pop(),
          onSharePressed: _shareClass,
        ),
        SizedBox(height: spec.sectionGap),
        ClassDetailHeroCard(
          session: _session,
          onMapPressed: _openMaps,
          onBookingPressed: _openConfirmationSheet,
        ),
        SizedBox(height: spec.sectionGap),
        ClassQuickGrid(session: _session),
        SizedBox(height: spec.sectionGap),
        ClassInfoSection(session: _session),
        SizedBox(height: spec.sectionGap),
        ClassSlotSection(
          slots: _session.slots,
          selectedIndex: _selectedSlotIndex,
          onSlotSelected: _changeSelectedSlotIndex,
          onResetPressed: _resetSelectedSlot,
        ),
        SizedBox(height: spec.sectionGap),
        ClassBenefitSection(benefits: _session.benefits),
        SizedBox(height: spec.sectionGap),
        ClassCoachCard(session: _session),
        SizedBox(height: spec.sectionGap),
        ClassActivityPreview(session: _session),
      ],
    );
  }

  Widget _buildExpandedContent(DetailClassLayoutSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClassDetailTopBar(
          onBackPressed: () => Navigator.of(context).pop(),
          onSharePressed: _shareClass,
        ),
        SizedBox(height: spec.sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 390,
              child: Column(
                children: [
                  ClassDetailHeroCard(
                    session: _session,
                    onMapPressed: _openMaps,
                    onBookingPressed: _openConfirmationSheet,
                  ),
                  SizedBox(height: spec.sectionGap),
                  ClassQuickGrid(session: _session),
                  SizedBox(height: spec.sectionGap),
                  ClassCoachCard(session: _session),
                ],
              ),
            ),
            SizedBox(width: spec.columnGap),
            Expanded(
              child: Column(
                children: [
                  ClassInfoSection(session: _session),
                  SizedBox(height: spec.sectionGap),
                  ClassSlotSection(
                    slots: _session.slots,
                    selectedIndex: _selectedSlotIndex,
                    onSlotSelected: _changeSelectedSlotIndex,
                    onResetPressed: _resetSelectedSlot,
                  ),
                  SizedBox(height: spec.sectionGap),
                  ClassBenefitSection(benefits: _session.benefits),
                  SizedBox(height: spec.sectionGap),
                  ClassActivityPreview(session: _session),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DetailClassLayoutSpec {
  const DetailClassLayoutSpec({
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

  factory DetailClassLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const DetailClassLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const DetailClassLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const DetailClassLayoutSpec(
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
