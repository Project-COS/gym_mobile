import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/colors.dart';
import '../../../bookings/data/repositories/personal_training_booking_repository.dart';
import '../../../bookings/presentation/screens/booking_success_screen.dart';
import '../../data/repositories/trainer_repository.dart';
import '../cubit/trainer_detail_cubit.dart';
import '../widgets/trainer_detail_widgets.dart';

class TrainerDetailScreen extends StatefulWidget {
  const TrainerDetailScreen({super.key, required this.trainerId});

  final String trainerId;

  @override
  State<TrainerDetailScreen> createState() => _TrainerDetailScreenState();
}

class _TrainerDetailScreenState extends State<TrainerDetailScreen> {
  late final TrainerDetailCubit _trainerDetailCubit;
  double _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _trainerDetailCubit = TrainerDetailCubit(
      repository: context.read<TrainerRepository>(),
      bookingRepository: context.read<PersonalTrainingBookingRepository>(),
      trainerId: widget.trainerId,
    )..fetchTrainer();
  }

  @override
  void dispose() {
    _trainerDetailCubit.close();
    super.dispose();
  }

  void _changeSelectedRating(double rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  Future<void> _openMaps(TrainerProfile trainer) async {
    final Uri mapsUri = trainer.mapUrl == null || trainer.mapUrl!.trim().isEmpty
        ? Uri.https('www.google.com', '/maps/search/', {
            'api': '1',
            'query': trainer.mapQuery,
          })
        : Uri.parse(trainer.mapUrl!);

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
      final isLaunched = await launchUrl(
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

  Future<void> _shareTrainer(TrainerProfile trainer) async {
    final shareText = '${trainer.name} - ${trainer.location}';

    await Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      _showMessage('Info trainer berhasil disalin.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrainerDetailCubit>.value(
      value: _trainerDetailCubit,
      child: Scaffold(
        backgroundColor: AppColors.blackCore,
        body: SafeArea(
          child: BlocConsumer<TrainerDetailCubit, TrainerDetailState>(
            listener: (context, state) {
              final successMessage = state.ratingSuccessMessage;
              final errorMessage = state.ratingErrorMessage;
              final bookingErrorMessage = state.bookingErrorMessage;
              final bookingConfirmation = state.bookingConfirmation;

              if (successMessage != null) {
                _showMessage(successMessage);
              }

              if (errorMessage != null) {
                _showMessage(errorMessage);
              }

              if (bookingErrorMessage != null) {
                _showMessage(bookingErrorMessage);
              }

              if (bookingConfirmation != null) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BookingSuccessScreen(
                      typeCode: 'pt',
                      itemId: bookingConfirmation.id,
                      title: bookingConfirmation.title,
                      schedule: bookingConfirmation.schedule,
                      duration: bookingConfirmation.duration,
                      location: bookingConfirmation.location,
                      bookingCode: bookingConfirmation.bookingCode,
                      qrPayload: bookingConfirmation.qrPayload,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final spec = TrainerDetailLayoutSpec.fromWidth(
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
                      RefreshIndicator(
                        color: AppColors.gymGold,
                        backgroundColor: AppColors.graphiteBlack,
                        onRefresh: () => context
                            .read<TrainerDetailCubit>()
                            .fetchTrainer(forceRefresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: spec.pagePadding,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: spec.maxContentWidth,
                              ),
                              child: _buildDetailContent(context, state, spec),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    TrainerDetailState state,
    TrainerDetailLayoutSpec spec,
  ) {
    final trainer = state.trainer;

    if (state.status == TrainerDetailLoadStatus.loading && trainer == null) {
      return const TrainerDetailStatusCard.loading();
    }

    if (state.status == TrainerDetailLoadStatus.failure && trainer == null) {
      return TrainerDetailStatusCard.failure(
        message:
            state.errorMessage ??
            'Detail trainer belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: () =>
            context.read<TrainerDetailCubit>().fetchTrainer(forceRefresh: true),
      );
    }

    if (trainer == null) {
      return TrainerDetailStatusCard.failure(
        message: 'Trainer tidak ditemukan.',
        onRetryPressed: () =>
            context.read<TrainerDetailCubit>().fetchTrainer(forceRefresh: true),
      );
    }

    return TrainerDetailView(
      trainer: trainer,
      selectedRating: _selectedRating,
      isSubmittingRating: state.isSubmittingRating,
      isSubmittingBooking: state.isSubmittingBooking,
      isExpanded: spec.isExpanded,
      sectionGap: spec.sectionGap,
      columnGap: spec.columnGap,
      onBackPressed: () => Navigator.of(context).pop(),
      onSharePressed: () => _shareTrainer(trainer),
      onMapPressed: () => _openMaps(trainer),
      onRatingChanged: _changeSelectedRating,
      onRatingSubmitted: () =>
          context.read<TrainerDetailCubit>().submitRating(_selectedRating),
      onBookingPressed: () => _openBookingSheet(trainer),
    );
  }

  void _openBookingSheet(TrainerProfile trainer) {
    final slots = _buildTrainerBookingSlots(trainer);

    if (slots.isEmpty) {
      _showMessage('Jadwal trainer belum tersedia untuk booking.');
      return;
    }

    TrainerProgram? selectedProgram = trainer.programs.isEmpty
        ? null
        : trainer.programs.first;
    _TrainerBookingSlot selectedSlot = slots.first;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                decoration: const BoxDecoration(
                  color: AppColors.graphiteBlack,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(top: BorderSide(color: AppColors.gunmetal)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.ironGray,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Booking Sesi PT',
                      style: TextStyle(
                        color: AppColors.metallicWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trainer.name,
                      style: const TextStyle(
                        color: AppColors.silverGray,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String?>(
                      value: selectedProgram?.id,
                      dropdownColor: AppColors.steelBlack,
                      decoration: _bookingSheetInputDecoration('Program'),
                      items: trainer.programs.isEmpty
                          ? const [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Program menyesuaikan'),
                              ),
                            ]
                          : trainer.programs
                                .map(
                                  (program) => DropdownMenuItem<String?>(
                                    value: program.id,
                                    child: Text(
                                      program.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                      onChanged: (programId) {
                        setSheetState(() {
                          selectedProgram = null;

                          for (final program in trainer.programs) {
                            if (program.id == programId) {
                              selectedProgram = program;
                              break;
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      value: slots.indexOf(selectedSlot),
                      dropdownColor: AppColors.steelBlack,
                      decoration: _bookingSheetInputDecoration('Jadwal'),
                      items: List<DropdownMenuItem<int>>.generate(
                        slots.length,
                        (index) => DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            slots[index].label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      onChanged: (slotIndex) {
                        if (slotIndex == null) {
                          return;
                        }

                        setSheetState(() {
                          selectedSlot = slots[slotIndex];
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _trainerDetailCubit.bookPersonalTrainingSession(
                            startsAt: selectedSlot.startsAt,
                            programId: selectedProgram?.id,
                            locationId:
                                selectedSlot.locationId ??
                                selectedProgram?.locationId ??
                                _defaultTrainerLocationId(trainer),
                          );
                        },
                        icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                        label: const Text('Konfirmasi booking'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.gymGold,
                          foregroundColor: AppColors.blackCore,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _bookingSheetInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.silverGray),
      filled: true,
      fillColor: AppColors.steelBlack,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gunmetal),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gymGold),
      ),
    );
  }

  String? _defaultTrainerLocationId(TrainerProfile trainer) {
    if (trainer.locations.isEmpty) {
      return null;
    }

    for (final location in trainer.locations) {
      if (location.isPrimary) {
        return location.id;
      }
    }

    return trainer.locations.first.id;
  }

  List<_TrainerBookingSlot> _buildTrainerBookingSlots(TrainerProfile trainer) {
    final now = DateTime.now();
    final slots = <_TrainerBookingSlot>[];

    for (final schedule in trainer.schedules) {
      final startTime = _parseScheduleStartTime(schedule.startTime);

      if (startTime == null) {
        continue;
      }

      final startsAt = _nextStartsAtForSchedule(
        now: now,
        dayOfWeek: schedule.dayOfWeek,
        startTime: startTime,
      );

      slots.add(
        _TrainerBookingSlot(
          startsAt: startsAt,
          locationId: schedule.locationId,
          label: _formatBookingSlotLabel(startsAt, schedule.locationName),
        ),
      );
    }

    if (slots.isEmpty) {
      final tomorrow = now.add(const Duration(days: 1));
      final fallbackStartsAt = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        9,
      );
      slots.add(
        _TrainerBookingSlot(
          startsAt: fallbackStartsAt,
          locationId: _defaultTrainerLocationId(trainer),
          label: _formatBookingSlotLabel(fallbackStartsAt, null),
        ),
      );
    }

    slots.sort((first, second) => first.startsAt.compareTo(second.startsAt));

    return slots.take(6).toList(growable: false);
  }

  TimeOfDay? _parseScheduleStartTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  DateTime _nextStartsAtForSchedule({
    required DateTime now,
    required int? dayOfWeek,
    required TimeOfDay startTime,
  }) {
    final targetWeekday = dayOfWeek == null
        ? now.add(const Duration(days: 1)).weekday
        : dayOfWeek == 0
        ? DateTime.sunday
        : dayOfWeek;
    var daysUntil = targetWeekday - now.weekday;

    if (daysUntil < 0) {
      daysUntil += 7;
    }

    var date = now.add(Duration(days: daysUntil));
    var startsAt = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    if (!startsAt.isAfter(now.add(const Duration(minutes: 5)))) {
      date = date.add(const Duration(days: 7));
      startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
    }

    return startsAt;
  }

  String _formatBookingSlotLabel(DateTime startsAt, String? locationName) {
    final dayName = _slotDayNames[startsAt.weekday % 7];
    final hour = startsAt.hour.toString().padLeft(2, '0');
    final minute = startsAt.minute.toString().padLeft(2, '0');
    final locationLabel = locationName == null || locationName.trim().isEmpty
        ? ''
        : ' - $locationName';

    return '$dayName, ${startsAt.day} ${_slotMonthNames[startsAt.month - 1]} $hour:$minute$locationLabel';
  }
}

class _TrainerBookingSlot {
  const _TrainerBookingSlot({
    required this.startsAt,
    required this.locationId,
    required this.label,
  });

  final DateTime startsAt;
  final String? locationId;
  final String label;
}

const List<String> _slotDayNames = [
  'Minggu',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
];

const List<String> _slotMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

class TrainerDetailLayoutSpec {
  const TrainerDetailLayoutSpec({
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

  factory TrainerDetailLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const TrainerDetailLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const TrainerDetailLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const TrainerDetailLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 18,
      columnGap: 0,
    );
  }
}

class TrainerDetailStatusCard extends StatelessWidget {
  const TrainerDetailStatusCard.loading({super.key})
    : message = 'Memuat detail trainer...',
      onRetryPressed = null;

  const TrainerDetailStatusCard.failure({
    super.key,
    required this.message,
    required this.onRetryPressed,
  });

  final String message;
  final VoidCallback? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final retryAction = onRetryPressed;

    return Container(
      constraints: const BoxConstraints(minHeight: 420),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Center(
        child: Row(
          children: [
            if (retryAction == null)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.gymGold,
                ),
              )
            else
              const Icon(
                Icons.info_rounded,
                color: AppColors.gymGold,
                size: 24,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (retryAction != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: retryAction,
                child: const Text(
                  'Coba lagi',
                  style: TextStyle(
                    color: AppColors.gymGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
