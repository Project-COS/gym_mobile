import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../core/colors.dart';
import '../../../../../core/icons/app_lucide_icons.dart';

// Presentational pieces for BookingSuccessScreen. Keeping them here makes the
// screen read as a simple ordered list of confirmation sections.
class BookingSuccessHero extends StatelessWidget {
  const BookingSuccessHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(minHeight: 146),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack.withValues(alpha: 0.94),
            AppColors.steelBlack.withValues(alpha: 0.82),
            AppColors.success.withValues(alpha: 0.18),
          ],
          stops: const [0, 0.68, 1],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.24)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -58,
            right: -48,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.16),
                    AppColors.success.withValues(alpha: 0.05),
                    AppColors.success.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.26),
                  ),
                ),
                child: const Icon(
                  AppLucideIcons.badgeCheck,
                  color: AppColors.success,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Booking berhasil',
                      style: TextStyle(
                        color: AppColors.metallicWhite,
                        fontSize: 22,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'QR check-in sudah siap untuk ditunjukkan saat tiba di lokasi.',
                      style: TextStyle(
                        color: AppColors.silverGray,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          const Text(
            'Kode booking',
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.gymGold,
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w900,
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
          const _SectionTitle('Detail booking'),
          const SizedBox(height: 16),
          _DetailRow(
            icon: AppLucideIcons.badgeCheck,
            label: 'Sesi',
            value: title,
          ),
          _DetailRow(
            icon: AppLucideIcons.calendarClock,
            label: 'Jadwal',
            value: schedule,
          ),
          _DetailRow(
            icon: AppLucideIcons.timer,
            label: 'Durasi',
            value: duration,
          ),
          _DetailRow(
            icon: AppLucideIcons.mapPin,
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
    final double qrSize = MediaQuery.sizeOf(context).width < 380 ? 184 : 208;

    // qr_flutter renders the payload locally; the API-provided payload is used
    // unchanged so staff scanners can validate the booking.
    return _SuccessCard(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: _SectionTitle('QR Check-in'),
          ),
          const SizedBox(height: 18),
          Container(
            width: qrSize,
            height: qrSize,
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
                size: qrSize - 28,
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
                  // Keep the card stable and readable if QR generation fails.
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
            'Tunjukkan QR ini ke staff DO GYM saat tiba di lokasi.',
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppLucideIcons.info, color: AppColors.paleGold, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hadir minimal 10 menit sebelum sesi dimulai. Simpan QR ini sampai check-in selesai.',
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
                label: 'Jadwal',
                icon: AppLucideIcons.calendarCheck,
                isPrimary: false,
                onPressed: onSchedulePressed,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BottomActionButton(
                label: 'Beranda',
                icon: AppLucideIcons.home,
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
        color: AppColors.graphiteBlack.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
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
        fontSize: 18,
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
                  label,
                  style: const TextStyle(
                    color: AppColors.ironGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? AppColors.gymGold
              : AppColors.steelBlack.withValues(alpha: 0.82),
          foregroundColor: isPrimary
              ? AppColors.blackCore
              : AppColors.metallicWhite,
          side: BorderSide(
            color: isPrimary ? AppColors.gymGold : AppColors.gunmetal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          iconColor: isPrimary ? AppColors.blackCore : AppColors.metallicWhite,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
