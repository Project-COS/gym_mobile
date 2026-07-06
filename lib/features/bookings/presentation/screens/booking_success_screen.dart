import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../widgets/booking_success/booking_success_widgets.dart';

// Shared confirmation/QR screen for PT and class bookings. Activity history can
// also reopen this screen to display an existing booking QR.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({
    super.key,
    required this.typeCode,
    required this.itemId,
    required this.title,
    required this.schedule,
    required this.duration,
    required this.location,
    this.bookingCode,
    this.qrPayload,
  });

  final String typeCode;
  final String itemId;
  final String title;
  final String schedule;
  final String duration;
  final String location;
  final String? bookingCode;
  final String? qrPayload;

  String get _bookingCode {
    final apiBookingCode = bookingCode;

    if (apiBookingCode != null && apiBookingCode.trim().isNotEmpty) {
      return apiBookingCode.trim();
    }

    // Fallback code keeps older/local flows usable if the API did not return a
    // booking code. API-provided codes always take precedence.
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

  String get _qrPayload {
    final apiQrPayload = qrPayload;

    if (apiQrPayload != null && apiQrPayload.trim().isNotEmpty) {
      return apiQrPayload.trim();
    }

    // Fallback payload is deterministic and type-scoped so staff tools can still
    // distinguish PT bookings from class bookings in local/demo flows.
    return '${typeCode == 'pt' ? 'pt_booking' : 'class_booking'}:$_bookingCode';
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
                    color: AppColors.success,
                    opacity: spec.isExpanded ? 0.07 : 0.08,
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
                          BookingQrCodeCard(
                            code: _bookingCode,
                            qrPayload: _qrPayload,
                          ),
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
            _showMessage(context, 'Jadwal tersimpan di riwayat aktivitas.'),
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
    // Keep QR and booking details readable by constraining the success page
    // width even on tablets and expanded layouts.
    if (width >= 840) {
      return const BookingSuccessLayoutSpec(
        isExpanded: true,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 28),
        sectionGap: 20,
        bottomGap: 32,
      );
    }

    if (width >= 600) {
      return const BookingSuccessLayoutSpec(
        isExpanded: false,
        maxContentWidth: 560,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 28),
        sectionGap: 20,
        bottomGap: 32,
      );
    }

    return const BookingSuccessLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 28),
      sectionGap: 20,
      bottomGap: 32,
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
