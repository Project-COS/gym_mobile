import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';

class BookingSuccessHero extends StatelessWidget {
  const BookingSuccessHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack,
            AppColors.steelBlack,
            AppColors.success.withValues(alpha: 0.32),
          ],
          stops: const [0, 0.55, 1.4],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.10),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.success,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'BOOKING CONFIRMED',
            style: TextStyle(
              color: AppColors.paleGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Booking Berhasil',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Jadwal latihan kamu sudah dikonfirmasi. Simpan kode booking dan gunakan barcode saat check-in.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingCodeCard extends StatelessWidget {
  const BookingCodeCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          const Text(
            'BOOKING CODE',
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gymGold,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSuccessDetailCard extends StatelessWidget {
  const BookingSuccessDetailCard({
    super.key,
    required this.title,
    required this.schedule,
    required this.duration,
    required this.location,
  });

  final String title;
  final String schedule;
  final String duration;
  final String location;

  @override
  Widget build(BuildContext context) {
    return _SuccessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Detail Booking'),
          const SizedBox(height: 12),
          _DetailRow(icon: Icons.verified_rounded, label: 'Sesi', value: title),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Jadwal',
            value: schedule,
          ),
          _DetailRow(
            icon: Icons.timer_rounded,
            label: 'Durasi',
            value: duration,
          ),
          _DetailRow(
            icon: Icons.location_on_rounded,
            label: 'Lokasi',
            value: location,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class BarcodeCheckInCard extends StatelessWidget {
  const BarcodeCheckInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SuccessCard(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: _SectionTitle('Barcode Check-in'),
          ),
          const SizedBox(height: 14),
          Container(
            width: 184,
            height: 92,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.metallicWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child: CustomPaint(painter: _BarcodePainter()),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tunjukkan barcode ini ke staff DO GYM saat tiba di lokasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingNoticeCard extends StatelessWidget {
  const BookingNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: AppColors.paleGold, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pastikan hadir minimal 10 menit sebelum sesi dimulai. Jadwal ini akan muncul di halaman Lihat Semua.',
              style: TextStyle(
                color: AppColors.paleGold,
                fontSize: 12,
                height: 1.7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSuccessBottomActions extends StatelessWidget {
  const BookingSuccessBottomActions({
    super.key,
    required this.onSchedulePressed,
    required this.onHomePressed,
  });

  final VoidCallback onSchedulePressed;
  final VoidCallback onHomePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.blackCore,
        border: Border(top: BorderSide(color: AppColors.gunmetal, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _BottomActionButton(
                label: 'Lihat Jadwal',
                icon: Icons.event_available_rounded,
                isPrimary: false,
                onPressed: onSchedulePressed,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BottomActionButton(
                label: 'Home',
                icon: Icons.home_rounded,
                isPrimary: true,
                onPressed: onHomePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.metallicWhite,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.gunmetal.withValues(alpha: 0.72),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.gymGold.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, color: AppColors.gymGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.ironGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.metallicWhite,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary ? AppColors.gymGold : AppColors.steelBlack,
          foregroundColor: isPrimary
              ? AppColors.blackCore
              : AppColors.metallicWhite,
          side: BorderSide(
            color: isPrimary ? AppColors.gymGold : AppColors.gunmetal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = AppColors.blackCore;
    const List<double> widths = [
      4,
      2,
      7,
      3,
      5,
      2,
      9,
      4,
      3,
      6,
      2,
      8,
      4,
      5,
      2,
      6,
      3,
      8,
    ];

    double x = 0;
    for (int index = 0; index < widths.length && x < size.width; index++) {
      final double width = widths[index];
      if (index.isEven) {
        canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), paint);
      }
      x += width + 4;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
