import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../../data/booking_data.dart';
import 'booking_success_screen.dart';
import '../widgets/detail_personal_trainer/detail_personal_trainer_widgets.dart';

class DetailPersonalTrainerScreen extends StatefulWidget {
  const DetailPersonalTrainerScreen({super.key, required this.session});

  final PersonalTrainerSession session;

  @override
  State<DetailPersonalTrainerScreen> createState() =>
      _DetailPersonalTrainerScreenState();
}

class _DetailPersonalTrainerScreenState
    extends State<DetailPersonalTrainerScreen> {
  int _selectedSlotIndex = 0;
  bool _isConfirmationOpen = false;

  PersonalTrainerSession get _session => widget.session;

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

  Future<void> _sharePersonalTrainer() async {
    final String shareText =
        '${_session.name} - ${_selectedSlot.label} di ${_session.branch}';

    await Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      _showMessage('Link berhasil disalin.');
    }
  }

  void _confirmBooking() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(
          typeCode: 'pt',
          itemId: _session.id,
          title: _session.name,
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
            final DetailPersonalTrainerLayoutSpec spec =
                DetailPersonalTrainerLayoutSpec.fromWidth(constraints.maxWidth);

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
                      child: PersonalTrainerDetailView(
                        session: _session,
                        selectedSlotIndex: _selectedSlotIndex,
                        isExpanded: spec.isExpanded,
                        sectionGap: spec.sectionGap,
                        columnGap: spec.columnGap,
                        onBackPressed: () => Navigator.of(context).pop(),
                        onSharePressed: _sharePersonalTrainer,
                        onMapPressed: _openMaps,
                        onBookingPressed: _openConfirmationSheet,
                        onSlotSelected: _changeSelectedSlotIndex,
                        onResetSlot: _resetSelectedSlot,
                      ),
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
                  child: PersonalTrainerBookingSheet(
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
}

class DetailPersonalTrainerLayoutSpec {
  const DetailPersonalTrainerLayoutSpec({
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

  factory DetailPersonalTrainerLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const DetailPersonalTrainerLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const DetailPersonalTrainerLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const DetailPersonalTrainerLayoutSpec(
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
