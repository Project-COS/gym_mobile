import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/repositories/personal_training_booking_repository.dart';
import 'booking_success_screen.dart';
import '../cubit/personal_training_booking_history_cubit.dart';

// Dedicated PT booking history screen. Class history is shown through the
// activity/classes flow, so this screen only owns PT filters and QR access.
class PersonalTrainingBookingHistoryScreen extends StatelessWidget {
  const PersonalTrainingBookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PersonalTrainingBookingHistoryCubit(
        repository: context.read<PersonalTrainingBookingRepository>(),
      )..fetchBookings(),
      child: const _PersonalTrainingBookingHistoryView(),
    );
  }
}

class _PersonalTrainingBookingHistoryView extends StatelessWidget {
  const _PersonalTrainingBookingHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackCore,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spec = _HistoryLayoutSpec.fromWidth(constraints.maxWidth);

            return BlocBuilder<
              PersonalTrainingBookingHistoryCubit,
              PersonalTrainingBookingHistoryState
            >(
              builder: (context, state) {
                return RefreshIndicator(
                  color: AppColors.gymGold,
                  backgroundColor: AppColors.graphiteBlack,
                  onRefresh: () => context
                      .read<PersonalTrainingBookingHistoryCubit>()
                      .fetchBookings(forceRefresh: true),
                  child: SingleChildScrollView(
                    // Always scrollable keeps pull-to-refresh available for
                    // loading, empty, and short history states.
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: spec.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: spec.maxContentWidth,
                          minHeight:
                              constraints.maxHeight - spec.pagePadding.vertical,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _HistoryHeader(),
                            SizedBox(height: spec.sectionGap),
                            _HistoryFilterSegment(state: state),
                            SizedBox(height: spec.sectionGap),
                            _HistoryContent(state: state),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History Booking PT',
          style: TextStyle(
            color: AppColors.metallicWhite,
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Pantau jadwal personal trainer, lihat QR booking aktif, dan cek sesi yang sudah selesai.',
          style: TextStyle(
            color: AppColors.silverGray,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _HistoryFilterSegment extends StatelessWidget {
  const _HistoryFilterSegment({required this.state});

  final PersonalTrainingBookingHistoryState state;

  @override
  Widget build(BuildContext context) {
    // SegmentedButton is appropriate here because the history has three
    // mutually exclusive filters.
    return SegmentedButton<PersonalTrainingBookingHistoryFilter>(
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gymGold;
          }

          return AppColors.graphiteBlack;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.blackCore;
          }

          return AppColors.metallicWhite;
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.gunmetal),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
      segments: const [
        ButtonSegment(
          value: PersonalTrainingBookingHistoryFilter.upcoming,
          label: Text('Aktif'),
          icon: Icon(AppLucideIcons.calendarClock, size: 16),
        ),
        ButtonSegment(
          value: PersonalTrainingBookingHistoryFilter.history,
          label: Text('Riwayat'),
          icon: Icon(AppLucideIcons.history, size: 16),
        ),
        ButtonSegment(
          value: PersonalTrainingBookingHistoryFilter.all,
          label: Text('Semua'),
          icon: Icon(AppLucideIcons.calendar, size: 16),
        ),
      ],
      selected: {state.filter},
      onSelectionChanged: state.isLoading
          ? null
          : (selection) {
              context.read<PersonalTrainingBookingHistoryCubit>().fetchBookings(
                filter: selection.first,
              );
            },
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.state});

  final PersonalTrainingBookingHistoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.bookings.isEmpty) {
      return const _HistoryStateMessage(
        icon: AppLucideIcons.calendarClock,
        title: 'Memuat booking',
        message: 'Sebentar, jadwal personal trainer sedang dimuat.',
        showProgress: true,
      );
    }

    if (state.status == PersonalTrainingBookingHistoryLoadStatus.failure) {
      return _HistoryStateMessage(
        icon: AppLucideIcons.info,
        title: 'Booking belum bisa dimuat',
        message:
            state.errorMessage ??
            'Riwayat booking belum bisa dimuat. Silakan coba kembali.',
        actionLabel: 'Coba lagi',
        onAction: () => context
            .read<PersonalTrainingBookingHistoryCubit>()
            .fetchBookings(forceRefresh: true),
      );
    }

    if (state.bookings.isEmpty) {
      return _HistoryStateMessage(
        icon: AppLucideIcons.calendarCheck,
        title: _emptyTitle(state.filter),
        message: _emptyMessage(state.filter),
      );
    }

    return Column(
      children: [
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(
              color: AppColors.gymGold,
              backgroundColor: AppColors.gunmetal,
            ),
          ),
        ...state.bookings.map(
          (booking) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BookingHistoryCard(booking: booking),
          ),
        ),
      ],
    );
  }

  String _emptyTitle(PersonalTrainingBookingHistoryFilter filter) {
    return switch (filter) {
      PersonalTrainingBookingHistoryFilter.upcoming =>
        'Belum ada booking aktif',
      PersonalTrainingBookingHistoryFilter.history => 'Riwayat masih kosong',
      PersonalTrainingBookingHistoryFilter.all => 'Belum ada booking PT',
    };
  }

  String _emptyMessage(PersonalTrainingBookingHistoryFilter filter) {
    return switch (filter) {
      PersonalTrainingBookingHistoryFilter.upcoming =>
        'Booking personal trainer yang masih aktif akan muncul di sini.',
      PersonalTrainingBookingHistoryFilter.history =>
        'Sesi selesai atau dibatalkan akan muncul di riwayat.',
      PersonalTrainingBookingHistoryFilter.all =>
        'Mulai booking personal trainer untuk melihat jadwal dan QR code.',
    };
  }
}

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({required this.booking});

  final PersonalTrainingBookingHistoryItem booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gymGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gymGold.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  AppLucideIcons.userPlus,
                  color: AppColors.gymGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      style: const TextStyle(
                        color: AppColors.metallicWhite,
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coach ${booking.trainerName}',
                      style: const TextStyle(
                        color: AppColors.silverGray,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 14),
          _DetailLine(
            icon: AppLucideIcons.calendarClock,
            text: booking.schedule,
          ),
          _DetailLine(icon: AppLucideIcons.timer, text: booking.duration),
          _DetailLine(icon: AppLucideIcons.mapPin, text: booking.location),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blackCore.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gunmetal),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kode Booking',
                        style: TextStyle(
                          color: AppColors.ironGray,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.bookingCode,
                        style: const TextStyle(
                          color: AppColors.paleGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (booking.canShowQr)
                  OutlinedButton.icon(
                    onPressed: () => _openBookingQr(context),
                    icon: const Icon(AppLucideIcons.qrCode, size: 16),
                    label: const Text('Lihat QR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gymGold,
                      side: const BorderSide(color: AppColors.gymGold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openBookingQr(BuildContext context) {
    // Reuse the confirmation screen so QR rendering and booking copy stay
    // consistent with newly-created bookings.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(
          typeCode: 'pt',
          itemId: booking.id,
          title: booking.title,
          schedule: booking.schedule,
          duration: booking.duration,
          location: booking.location,
          bookingCode: booking.bookingCode,
          qrPayload: booking.qrPayload,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.ironGray, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.silverGray,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _statusColor.withValues(alpha: 0.38)),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          color: _statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color get _statusColor {
    return switch (status) {
      'SCHEDULED' => AppColors.info,
      'REQUESTED' => AppColors.warning,
      'COMPLETED' => AppColors.success,
      'CANCELLED' || 'NO_SHOW' => AppColors.error,
      _ => AppColors.silverGray,
    };
  }

  String get _statusLabel {
    return switch (status) {
      'SCHEDULED' => 'Aktif',
      'REQUESTED' => 'Menunggu',
      'COMPLETED' => 'Selesai',
      'CANCELLED' => 'Batal',
      'NO_SHOW' => 'Tidak Hadir',
      _ => status,
    };
  }
}

class _HistoryStateMessage extends StatelessWidget {
  const _HistoryStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.showProgress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gymGold, size: 40),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 18),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.gymGold,
                strokeWidth: 3,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gymGold,
                foregroundColor: AppColors.blackCore,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryLayoutSpec {
  const _HistoryLayoutSpec({
    required this.maxContentWidth,
    required this.pagePadding,
    required this.sectionGap,
  });

  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final double sectionGap;

  factory _HistoryLayoutSpec.fromWidth(double width) {
    // Match the app's shared responsive breakpoints while keeping history cards
    // narrow enough for comfortable reading.
    if (width >= 840) {
      return const _HistoryLayoutSpec(
        maxContentWidth: 680,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 18,
      );
    }

    if (width >= 600) {
      return const _HistoryLayoutSpec(
        maxContentWidth: 620,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 18,
      );
    }

    return const _HistoryLayoutSpec(
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 16,
    );
  }
}
