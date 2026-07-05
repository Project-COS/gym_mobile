import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/colors.dart';

class BookingSuccessHero extends StatelessWidget {
  const BookingSuccessHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(minHeight: 174),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack.withValues(alpha: 0.98),
            AppColors.steelBlack.withValues(alpha: 0.86),
            AppColors.success.withValues(alpha: 0.32),
          ],
          stops: const [0, 0.62, 1.26],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -70,
            right: -42,
            child: Container(
              width: 146,
              height: 146,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.16),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.34),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.13),
                      blurRadius: 42,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'BOOKING CONFIRMED',
                style: TextStyle(
                  color: AppColors.paleGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gymGold.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
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
              fontSize: 27,
              height: 1.1,
              fontWeight: FontWeight.w900,
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
          const SizedBox(height: 16),
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

class BookingQrCodeCard extends StatelessWidget {
  const BookingQrCodeCard({
    super.key,
    required this.code,
    required this.qrPayload,
  });

  final String code;
  final String qrPayload;

  @override
  Widget build(BuildContext context) {
    return _SuccessCard(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: _SectionTitle('Barcode Check-in'),
          ),
          const SizedBox(height: 18),
          Container(
            width: 214,
            height: 168,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.metallicWhite,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackCore.withValues(alpha: 0.36),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Center(
              child: QrImageView(
                data: qrPayload,
                version: QrVersions.auto,
                backgroundColor: AppColors.metallicWhite,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.blackCore,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.blackCore,
                ),
                padding: EdgeInsets.zero,
                gapless: false,
                semanticsLabel: 'Kode check-in booking $code',
                errorStateBuilder: (_, _) {
                  return const Center(
                    child: Text(
                      'Kode check-in belum bisa ditampilkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackCore,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tunjukkan barcode ini ke staff DO GYM saat tiba di lokasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
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
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w900,
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gymGold.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, color: AppColors.gymGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.ironGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.metallicWhite,
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w900,
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
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
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
            borderRadius: BorderRadius.circular(18),
          ),
          iconColor: isPrimary ? AppColors.blackCore : AppColors.metallicWhite,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
