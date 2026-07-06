import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/colors.dart';
import '../cubit/member_attendance_qr_cubit.dart';

// Bottom sheet for member check-in/check-out barcode. The Cubit is provided by
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
                            Center(
                              child: Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Barcode Member',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.metallicWhite,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tunjukkan barcode ini ke staff saat datang atau pulang dari gym.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.silverGray,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
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
        message: state.errorMessage ?? 'Barcode member belum bisa dibuat.',
      );
    }

    if (qr == null) {
      return _MemberAttendanceQrErrorState(
        message: 'Barcode member belum tersedia.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: QrImageView(
              // qrPayload is the scanner contract; never replace it with member code.
              data: qr.qrPayload,
              version: QrVersions.auto,
              size: 220,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _MemberAttendanceQrInfo(
          memberName: qr.memberName,
          memberCode: qr.memberCode,
          planName: qr.planName,
          membershipExpiryLabel: qr.membershipExpiryLabel,
          qrExpiryLabel: qr.qrExpiryLabel,
        ),
        if (state.status == MemberAttendanceQrLoadStatus.failure) ...[
          const SizedBox(height: 12),
          // Refresh failures keep the previous QR visible and show the issue inline.
          Text(
            state.errorMessage ?? 'Barcode member belum bisa diperbarui.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 18),
        FilledButton.icon(
          // Manual refresh requests a new short-lived payload from the backend.
          onPressed: state.isLoading
              ? null
              : () => context.read<MemberAttendanceQrCubit>().createQr(
                  forceRefresh: true,
                ),
          icon: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(state.isLoading ? 'Memperbarui...' : 'Perbarui Barcode'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gymGold,
            foregroundColor: AppColors.blackCore,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _MemberAttendanceQrLoadingState extends StatelessWidget {
  const _MemberAttendanceQrLoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.gymGold),
            SizedBox(height: 14),
            Text(
              'Membuat barcode member...',
              style: TextStyle(color: AppColors.silverGray, fontSize: 13),
            ),
          ],
        ),
      ),
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
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.silverGray,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.read<MemberAttendanceQrCubit>().createQr(
            forceRefresh: true,
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Coba Lagi'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gymGold,
            foregroundColor: AppColors.blackCore,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _MemberAttendanceQrInfo extends StatelessWidget {
  const _MemberAttendanceQrInfo({
    required this.memberName,
    required this.memberCode,
    required this.planName,
    required this.membershipExpiryLabel,
    required this.qrExpiryLabel,
  });

  final String memberName;
  final String memberCode;
  final String planName;
  final String membershipExpiryLabel;
  final String qrExpiryLabel;

  @override
  Widget build(BuildContext context) {
    // Human-readable member and membership data supports staff verification.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
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
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            memberCode,
            style: const TextStyle(
              color: AppColors.paleGold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _MemberAttendanceQrInfoRow(label: 'Paket', value: planName),
          const SizedBox(height: 8),
          _MemberAttendanceQrInfoRow(
            label: 'Aktif sampai',
            value: membershipExpiryLabel,
          ),
          const SizedBox(height: 8),
          _MemberAttendanceQrInfoRow(
            label: 'Barcode berlaku sampai',
            value: qrExpiryLabel,
          ),
        ],
      ),
    );
  }
}

class _MemberAttendanceQrInfoRow extends StatelessWidget {
  const _MemberAttendanceQrInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.silverGray, fontSize: 12),
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
