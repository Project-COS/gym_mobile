import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../cubit/member_attendance_qr_cubit.dart';

// Bottom sheet for member check-in/check-out QR. The Cubit is provided by
// the caller so this widget only renders QR state and refresh actions.
class MemberAttendanceQrSheet extends StatelessWidget {
  const MemberAttendanceQrSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              // Keep short states visually anchored to the sheet height.
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child:
                    BlocBuilder<
                      MemberAttendanceQrCubit,
                      MemberAttendanceQrState
                    >(
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _MemberAttendanceSheetHandle(),
                            const SizedBox(height: 18),
                            const _MemberAttendanceQrHeader(),
                            const SizedBox(height: 20),
                            _buildContent(context, state),
                          ],
                        );
                      },
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MemberAttendanceQrState state) {
    final qr = state.qr;

    // First load has no fallback QR yet, so show a dedicated loading state.
    if (state.status == MemberAttendanceQrLoadStatus.loading && qr == null) {
      return const _MemberAttendanceQrLoadingState();
    }

    // Initial failure needs a full error state because there is nothing to scan.
    if (state.status == MemberAttendanceQrLoadStatus.failure && qr == null) {
      return _MemberAttendanceQrErrorState(
        message: state.errorMessage ?? 'QR member belum bisa dibuat.',
      );
    }

    if (qr == null) {
      return _MemberAttendanceQrErrorState(
        message: 'QR member belum tersedia.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MemberAttendanceQrCodeCard(
          qrPayload: qr.qrPayload,
          memberCode: qr.memberCode,
        ),
        const SizedBox(height: 16),
        _MemberAttendanceQrInfo(
          memberName: qr.memberName,
          memberCode: qr.memberCode,
          planName: qr.planName,
          membershipExpiryLabel: qr.membershipExpiryLabel,
        ),
        if (state.status == MemberAttendanceQrLoadStatus.failure) ...[
          const SizedBox(height: 12),
          // Refresh failures keep the previous QR visible and show the issue inline.
          Text(
            state.errorMessage ?? 'QR member belum bisa diperbarui.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 18),
        _MemberAttendanceRefreshButton(
          isLoading: state.isLoading,
          onPressed: () => context.read<MemberAttendanceQrCubit>().createQr(
            forceRefresh: true,
          ),
        ),
      ],
    );
  }
}

class _MemberAttendanceSheetHandle extends StatelessWidget {
  const _MemberAttendanceSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.gunmetal.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class _MemberAttendanceQrHeader extends StatelessWidget {
  const _MemberAttendanceQrHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gymGold.withValues(alpha: 0.18),
            ),
          ),
          child: const Icon(
            AppLucideIcons.qrScanner,
            color: AppColors.gymGold,
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QR Member',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 22,
                  height: 1.14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Tunjukkan QR ini ke staff saat datang atau pulang dari gym.',
                style: TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberAttendanceQrCodeCard extends StatelessWidget {
  const _MemberAttendanceQrCodeCard({
    required this.qrPayload,
    required this.memberCode,
  });

  final String qrPayload;
  final String memberCode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double qrFrameSize = (constraints.maxWidth - 76)
            .clamp(218.0, 260.0)
            .toDouble();
        final double qrSize = qrFrameSize - 34;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.graphiteBlack.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gunmetal.withValues(alpha: 0.78),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: qrFrameSize,
                height: qrFrameSize,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: QrImageView(
                  // qrPayload is the scanner contract; never replace it with member code.
                  data: qrPayload,
                  version: QrVersions.auto,
                  size: qrSize,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.zero,
                  gapless: false,
                  semanticsLabel: 'QR check-in member $memberCode',
                  errorStateBuilder: (_, _) => const Center(
                    child: Text(
                      'QR belum bisa ditampilkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackCore,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppLucideIcons.qrCode,
                    color: AppColors.gymGold,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Siap discan untuk check-in atau check-out.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.silverGray,
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberAttendanceQrLoadingState extends StatelessWidget {
  const _MemberAttendanceQrLoadingState();

  @override
  Widget build(BuildContext context) {
    return const _MemberAttendanceQrStatusCard(
      icon: AppLucideIcons.qrScanner,
      title: 'Menyiapkan QR',
      message: 'Membuat QR member untuk check-in atau check-out.',
      isLoading: true,
    );
  }
}

class _MemberAttendanceQrErrorState extends StatelessWidget {
  const _MemberAttendanceQrErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    // Used only when no QR has been created yet.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MemberAttendanceQrStatusCard(
          icon: AppLucideIcons.info,
          title: 'QR belum siap',
          message: message,
        ),
        const SizedBox(height: 16),
        _MemberAttendanceRefreshButton(
          label: 'Coba lagi',
          onPressed: () => context.read<MemberAttendanceQrCubit>().createQr(
            forceRefresh: true,
          ),
        ),
      ],
    );
  }
}

class _MemberAttendanceQrStatusCard extends StatelessWidget {
  const _MemberAttendanceQrStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 214),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.gymGold.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gymGold.withValues(alpha: 0.18),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isLoading)
                      CircularProgressIndicator(
                        strokeWidth: 2.4,
                        strokeCap: StrokeCap.round,
                        color: AppColors.gymGold,
                        backgroundColor: AppColors.gymGold.withValues(
                          alpha: 0.10,
                        ),
                        semanticsLabel: 'Memuat QR member',
                      ),
                    Icon(icon, color: AppColors.gymGold, size: 23),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberAttendanceQrInfo extends StatelessWidget {
  const _MemberAttendanceQrInfo({
    required this.memberName,
    required this.memberCode,
    required this.planName,
    required this.membershipExpiryLabel,
  });

  final String memberName;
  final String memberCode;
  final String planName;
  final String membershipExpiryLabel;

  @override
  Widget build(BuildContext context) {
    // Human-readable member and membership data supports staff verification.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gymGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.gymGold.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  AppLucideIcons.person,
                  color: AppColors.gymGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.metallicWhite,
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      memberCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.paleGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppColors.gunmetal.withValues(alpha: 0.62),
          ),
          const SizedBox(height: 14),
          _MemberAttendanceQrInfoRow(
            icon: AppLucideIcons.badgeCheck,
            label: 'Paket',
            value: planName,
          ),
          const SizedBox(height: 10),
          _MemberAttendanceQrInfoRow(
            icon: AppLucideIcons.calendarCheck,
            label: 'Aktif sampai',
            value: membershipExpiryLabel,
          ),
        ],
      ),
    );
  }
}

class _MemberAttendanceRefreshButton extends StatelessWidget {
  const _MemberAttendanceRefreshButton({
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Perbarui QR',
  });

  final VoidCallback onPressed;
  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        // Manual refresh requests a new short-lived payload from the backend.
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.blackCore,
                ),
              )
            : const Icon(AppLucideIcons.history, size: 18),
        label: Text(isLoading ? 'Memperbarui...' : label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gymGold,
          disabledBackgroundColor: AppColors.gymGold.withValues(alpha: 0.58),
          foregroundColor: AppColors.blackCore,
          disabledForegroundColor: AppColors.blackCore.withValues(alpha: 0.72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _MemberAttendanceQrInfoRow extends StatelessWidget {
  const _MemberAttendanceQrInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.gymGold, size: 16),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
