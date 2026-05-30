import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import 'widget/booking_success_widgets.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({
    super.key,
    required this.typeCode,
    required this.itemId,
    required this.title,
    required this.schedule,
    required this.duration,
    required this.location,
  });

  final String typeCode;
  final String itemId;
  final String title;
  final String schedule;
  final String duration;
  final String location;

  String get _bookingCode {
    final String cleanId = itemId
        .replaceAll(RegExp('[^a-zA-Z0-9]'), '')
        .toUpperCase()
        .padRight(4, 'X')
        .substring(0, 4);
    final String normalizedType = typeCode == 'pt' ? 'PT' : 'CL';
    final int seed = itemId.codeUnits.fold<int>(
      0,
      (total, codeUnit) => total + codeUnit,
    );
    final String number = (seed % 999).toString().padLeft(3, '0');

    return 'DGYM-$normalizedType-$cleanId-$number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackCore,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final BookingSuccessLayoutSpec spec =
                BookingSuccessLayoutSpec.fromWidth(constraints.maxWidth);

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
                    color: AppColors.success,
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
                      child: Column(
                        children: [
                          const BookingSuccessHero(),
                          SizedBox(height: spec.sectionGap),
                          BookingCodeCard(code: _bookingCode),
                          SizedBox(height: spec.sectionGap),
                          BookingSuccessDetailCard(
                            title: title,
                            schedule: schedule,
                            duration: duration,
                            location: location,
                          ),
                          SizedBox(height: spec.sectionGap),
                          const BarcodeCheckInCard(),
                          SizedBox(height: spec.sectionGap),
                          const BookingNoticeCard(),
                          SizedBox(height: spec.bottomGap),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BookingSuccessBottomActions(
        onSchedulePressed: () =>
            _showMessage(context, 'Jadwal belum tersedia di versi ini.'),
        onHomePressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class BookingSuccessLayoutSpec {
  const BookingSuccessLayoutSpec({
    required this.isExpanded,
    required this.maxContentWidth,
    required this.pagePadding,
    required this.sectionGap,
    required this.bottomGap,
  });

  final bool isExpanded;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final double sectionGap;
  final double bottomGap;

  factory BookingSuccessLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const BookingSuccessLayoutSpec(
        isExpanded: true,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 24),
        sectionGap: 18,
        bottomGap: 24,
      );
    }

    if (width >= 600) {
      return const BookingSuccessLayoutSpec(
        isExpanded: false,
        maxContentWidth: 560,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 24),
        sectionGap: 16,
        bottomGap: 24,
      );
    }

    return const BookingSuccessLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 16,
      bottomGap: 24,
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
