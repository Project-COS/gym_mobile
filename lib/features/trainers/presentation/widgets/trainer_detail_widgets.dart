import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/repositories/trainer_repository.dart';

/// Komposisi utama detail trainer.
///
/// File ini hanya merakit section UI dari TrainerProfile. Aksi seperti fetch,
/// rating, booking, Maps, dan share dikirim sebagai callback dari screen.
class TrainerDetailView extends StatelessWidget {
  const TrainerDetailView({
    super.key,
    required this.trainer,
    required this.selectedRating,
    required this.isSubmittingRating,
    required this.isSubmittingBooking,
    required this.isExpanded,
    required this.sectionGap,
    required this.columnGap,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onMapPressed,
    required this.onRatingChanged,
    required this.onRatingSubmitted,
    required this.onBookingPressed,
  });

  final TrainerProfile trainer;
  final double selectedRating;
  final bool isSubmittingRating;
  final bool isSubmittingBooking;
  final bool isExpanded;
  final double sectionGap;
  final double columnGap;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onMapPressed;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onRatingSubmitted;
  final VoidCallback onBookingPressed;

  @override
  Widget build(BuildContext context) {
    // Detail memakai dua komposisi agar tablet/desktop tidak hanya menjadi
    // versi mobile yang melebar.
    if (isExpanded) {
      return _buildExpandedContent();
    }

    return _buildStackedContent();
  }

  Widget _buildStackedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrainerDetailTopBar(
          onBackPressed: onBackPressed,
          onSharePressed: onSharePressed,
        ),
        SizedBox(height: sectionGap),
        TrainerHeroCard(
          trainer: trainer,
          isSubmittingBooking: isSubmittingBooking,
          onBookingPressed: onBookingPressed,
          onMapPressed: onMapPressed,
        ),
        SizedBox(height: sectionGap),
        TrainerQuickGrid(trainer: trainer),
        SizedBox(height: sectionGap),
        TrainerInfoSection(trainer: trainer),
        SizedBox(height: sectionGap),
        TrainerScheduleSection(schedules: trainer.schedules),
        SizedBox(height: sectionGap),
        TrainerProgramSection(programs: trainer.programs),
        SizedBox(height: sectionGap),
        TrainerBookingActionCard(
          isSubmitting: isSubmittingBooking,
          onBookingPressed: onBookingPressed,
        ),
        SizedBox(height: sectionGap),
        TrainerRatingSection(
          trainer: trainer,
          selectedRating: selectedRating,
          isSubmitting: isSubmittingRating,
          onRatingChanged: onRatingChanged,
          onSubmitPressed: onRatingSubmitted,
        ),
        SizedBox(height: sectionGap),
        TrainerBenefitSection(benefits: trainer.benefits),
        SizedBox(height: sectionGap),
        TrainerGallerySection(gallery: trainer.gallery),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrainerDetailTopBar(
          onBackPressed: onBackPressed,
          onSharePressed: onSharePressed,
        ),
        SizedBox(height: sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 390,
              child: Column(
                children: [
                  TrainerHeroCard(
                    trainer: trainer,
                    isSubmittingBooking: isSubmittingBooking,
                    onBookingPressed: onBookingPressed,
                    onMapPressed: onMapPressed,
                  ),
                  SizedBox(height: sectionGap),
                  TrainerQuickGrid(trainer: trainer),
                  SizedBox(height: sectionGap),
                  TrainerBookingActionCard(
                    isSubmitting: isSubmittingBooking,
                    onBookingPressed: onBookingPressed,
                  ),
                ],
              ),
            ),
            SizedBox(width: columnGap),
            Expanded(
              child: Column(
                children: [
                  TrainerInfoSection(trainer: trainer),
                  SizedBox(height: sectionGap),
                  TrainerScheduleSection(schedules: trainer.schedules),
                  SizedBox(height: sectionGap),
                  TrainerProgramSection(programs: trainer.programs),
                  SizedBox(height: sectionGap),
                  TrainerRatingSection(
                    trainer: trainer,
                    selectedRating: selectedRating,
                    isSubmitting: isSubmittingRating,
                    onRatingChanged: onRatingChanged,
                    onSubmitPressed: onRatingSubmitted,
                  ),
                  SizedBox(height: sectionGap),
                  TrainerBenefitSection(benefits: trainer.benefits),
                  SizedBox(height: sectionGap),
                  TrainerGallerySection(gallery: trainer.gallery),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TrainerBookingActionCard extends StatelessWidget {
  const TrainerBookingActionCard({
    super.key,
    required this.isSubmitting,
    required this.onBookingPressed,
  });

  final bool isSubmitting;
  final VoidCallback onBookingPressed;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Booking Sesi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih program dan jadwal yang tersedia untuk membuat QR booking.',
            style: TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : onBookingPressed,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.blackCore,
                      ),
                    )
                  : const Icon(AppLucideIcons.calendarClock, size: 16),
              label: Text(
                isSubmitting ? 'Membuat booking...' : 'Pilih jadwal PT',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.gymGold,
                foregroundColor: AppColors.blackCore,
                disabledBackgroundColor: AppColors.darkGold,
                disabledForegroundColor: AppColors.blackCore,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
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
    );
  }
}

class TrainerDetailTopBar extends StatelessWidget {
  const TrainerDetailTopBar({
    super.key,
    required this.onBackPressed,
    required this.onSharePressed,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              _IconActionButton(
                icon: AppLucideIcons.chevronLeft,
                label: 'Kembali',
                isPrimary: false,
                onPressed: onBackPressed,
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail trainer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.silverGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Trainer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.metallicWhite,
                        fontSize: 21,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconActionButton(
          icon: AppLucideIcons.share,
          label: 'Bagikan',
          isPrimary: true,
          onPressed: onSharePressed,
        ),
      ],
    );
  }
}

class TrainerHeroCard extends StatelessWidget {
  const TrainerHeroCard({
    super.key,
    required this.trainer,
    required this.isSubmittingBooking,
    required this.onBookingPressed,
    required this.onMapPressed,
  });

  final TrainerProfile trainer;
  final bool isSubmittingBooking;
  final VoidCallback onBookingPressed;
  final VoidCallback onMapPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 318,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.24)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: _HeroCover(imageUrl: trainer.coverImageUrl)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.blackCore.withValues(alpha: 0.08),
                    AppColors.blackCore.withValues(alpha: 0.58),
                    AppColors.blackCore.withValues(alpha: 0.94),
                  ],
                  stops: const [0, 0.52, 1],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _HeroLabel(),
                  _RatingChip(rating: trainer.ratingLabel),
                ],
              ),
              const Spacer(),
              Text(
                trainer.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 28,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                trainer.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.metallicWhite.withValues(alpha: 0.86),
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: isSubmittingBooking
                            ? null
                            : onBookingPressed,
                        icon: isSubmittingBooking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blackCore,
                                ),
                              )
                            : const Icon(
                                AppLucideIcons.calendarClock,
                                size: 16,
                              ),
                        label: Text(
                          isSubmittingBooking ? 'Membuat...' : 'Booking PT',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.gymGold,
                          foregroundColor: AppColors.blackCore,
                          disabledBackgroundColor: AppColors.darkGold,
                          disabledForegroundColor: AppColors.blackCore,
                          side: const BorderSide(color: AppColors.gymGold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: onMapPressed,
                        icon: const Icon(AppLucideIcons.navigation, size: 16),
                        label: const Text(
                          'Maps',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.metallicWhite,
                          side: BorderSide(
                            color: AppColors.gunmetal.withValues(alpha: 0.84),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TrainerQuickGrid extends StatelessWidget {
  const TrainerQuickGrid({super.key, required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickInfoItem(
        icon: AppLucideIcons.clock,
        label: 'Jadwal',
        value: trainer.scheduleLabel,
      ),
      _QuickInfoItem(
        icon: AppLucideIcons.timer,
        label: 'Durasi',
        value: trainer.duration,
      ),
      _QuickInfoItem(
        icon: AppLucideIcons.mapPin,
        label: 'Cabang',
        value: trainer.branch,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return _QuickInfoPanel(items: items);
        }

        return Row(
          children: [
            Expanded(
              child: _QuickCard(
                icon: items[0].icon,
                label: items[0].label,
                value: items[0].value,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickCard(
                icon: items[1].icon,
                label: items[1].label,
                value: items[1].value,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickCard(
                icon: items[2].icon,
                label: items[2].label,
                value: items[2].value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickInfoItem {
  const _QuickInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _QuickInfoPanel extends StatelessWidget {
  const _QuickInfoPanel({required this.items});

  final List<_QuickInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: _QuickInfoRow(item: item),
          );
        }),
      ),
    );
  }
}

class _QuickInfoRow extends StatelessWidget {
  const _QuickInfoRow({required this.item});

  final _QuickInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBadge(icon: item.icon, size: 34, iconSize: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TrainerInfoSection extends StatelessWidget {
  const TrainerInfoSection({super.key, required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Informasi Trainer',
      child: Column(
        children: [
          _InfoRow(
            icon: AppLucideIcons.badgeCheck,
            label: 'Spesialisasi',
            value: trainer.specialization,
          ),
          _InfoRow(
            icon: AppLucideIcons.mapPin,
            label: 'Lokasi',
            value: trainer.location,
          ),
          _InfoRow(
            icon: AppLucideIcons.dumbbell,
            label: 'Jenis Program',
            value: trainer.programType,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class TrainerRatingSection extends StatelessWidget {
  const TrainerRatingSection({
    super.key,
    required this.trainer,
    required this.selectedRating,
    required this.isSubmitting,
    required this.onRatingChanged,
    required this.onSubmitPressed,
  });

  final TrainerProfile trainer;
  final double selectedRating;
  final bool isSubmitting;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onSubmitPressed;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Rating Trainer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                AppLucideIcons.star,
                color: AppColors.gymGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                trainer.ratingLabel,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Rating dari member',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.silverGray, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!trainer.canRate)
            const Text(
              'Kamu bisa memberi rating setelah menyelesaikan sesi dengan trainer ini.',
              style: TextStyle(
                color: AppColors.silverGray,
                fontSize: 12,
                height: 1.6,
              ),
            )
          else ...[
            _RatingStars(
              selectedRating: selectedRating,
              onRatingChanged: onRatingChanged,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmitPressed,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.blackCore,
                        ),
                      )
                    : const Icon(AppLucideIcons.star, size: 16),
                label: Text(isSubmitting ? 'Mengirim...' : 'Kirim rating'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.gymGold,
                  foregroundColor: AppColors.blackCore,
                  disabledBackgroundColor: AppColors.darkGold,
                  disabledForegroundColor: AppColors.blackCore,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TrainerScheduleSection extends StatelessWidget {
  const TrainerScheduleSection({super.key, required this.schedules});

  final List<TrainerSchedule> schedules;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Jadwal Tersedia',
      child: schedules.isEmpty
          ? const Text(
              'Jadwal trainer belum tersedia.',
              style: TextStyle(
                color: AppColors.silverGray,
                fontSize: 12,
                height: 1.6,
              ),
            )
          : Column(
              children: List.generate(schedules.length, (index) {
                final schedule = schedules[index];
                final isLast = index == schedules.length - 1;

                return _InfoRow(
                  icon: AppLucideIcons.calendarClock,
                  label: schedule.locationName ?? 'Cabang',
                  value: schedule.label,
                  isLast: isLast,
                );
              }),
            ),
    );
  }
}

class TrainerProgramSection extends StatelessWidget {
  const TrainerProgramSection({super.key, required this.programs});

  final List<TrainerProgram> programs;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Program Trainer',
      child: programs.isEmpty
          ? const Text(
              'Program trainer belum tersedia.',
              style: TextStyle(
                color: AppColors.silverGray,
                fontSize: 12,
                height: 1.6,
              ),
            )
          : Column(
              children: List.generate(programs.length, (index) {
                final program = programs[index];
                final isLast = index == programs.length - 1;

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: _ProgramTile(program: program),
                );
              }),
            ),
    );
  }
}

class TrainerBenefitSection extends StatelessWidget {
  const TrainerBenefitSection({super.key, required this.benefits});

  final List<TrainerBenefit> benefits;

  @override
  Widget build(BuildContext context) {
    if (benefits.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: 'Yang Kamu Dapat',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 420 ? 2 : 1;
          final tileWidth = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - 10) / 2;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: benefits
                .map(
                  (benefit) => SizedBox(
                    width: tileWidth,
                    child: _BenefitTile(benefit: benefit),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.benefit});

  final TrainerBenefit benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.steelBlack.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.70)),
      ),
      child: Row(
        children: [
          _IconBadge(icon: benefit.icon, size: 36, iconSize: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.metallicWhite,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrainerGallerySection extends StatelessWidget {
  const TrainerGallerySection({super.key, required this.gallery});

  final List<String> gallery;

  @override
  Widget build(BuildContext context) {
    if (gallery.isEmpty) {
      // Gallery adalah konten tambahan, bukan empty state utama detail trainer.
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galeri',
          style: TextStyle(
            color: AppColors.metallicWhite,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _ActivityImage(imageUrl: gallery[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({
    required this.selectedRating,
    required this.onRatingChanged,
  });

  final double selectedRating;
  final ValueChanged<double> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final ratingValue = (index + 1).toDouble();
        final isSelected = ratingValue <= selectedRating;

        return IconButton(
          tooltip: '$ratingValue bintang',
          onPressed: () => onRatingChanged(ratingValue),
          icon: Icon(
            AppLucideIcons.star,
            color: isSelected ? AppColors.gymGold : AppColors.ironGray,
            size: 34,
          ),
        );
      }),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  const _ProgramTile({required this.program});

  final TrainerProgram program;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.steelBlack.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.72)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconBadge(icon: AppLucideIcons.dumbbell),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.metallicWhite,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${program.duration} - ${program.focus}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.silverGray,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                if (program.locationName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    program.locationName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gymGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: isPrimary
                ? AppColors.gymGold
                : AppColors.graphiteBlack,
            foregroundColor: isPrimary
                ? AppColors.blackCore
                : AppColors.metallicWhite,
            side: BorderSide(
              color: isPrimary ? AppColors.gymGold : AppColors.gunmetal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCover extends StatelessWidget {
  const _HeroCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // Hero cover sengaja redup karena teks utama ditempatkan di atas gambar.
    return Opacity(
      opacity: 0.28,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BrokenImageFallback(),
      ),
    );
  }
}

class _BrokenImageFallback extends StatelessWidget {
  const _BrokenImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.steelBlack,
      child: Center(
        child: Icon(AppLucideIcons.info, color: AppColors.ironGray, size: 36),
      ),
    );
  }
}

class _HeroLabel extends StatelessWidget {
  const _HeroLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.blackCore.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.16)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppLucideIcons.userPlus, color: AppColors.gymGold, size: 14),
          SizedBox(width: 7),
          Text(
            'Trainer personal',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.gymGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppLucideIcons.star, color: AppColors.gymGold, size: 14),
          const SizedBox(width: 6),
          Text(
            rating,
            style: const TextStyle(
              color: AppColors.gymGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: icon, size: 34, iconSize: 17),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.size = 38, this.iconSize = 18});

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size >= 38 ? 14 : 12),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: AppColors.gymGold, size: iconSize),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.metallicWhite,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.graphiteBlack.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.gunmetal.withValues(alpha: 0.78),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
                  color: AppColors.gunmetal.withValues(alpha: 0.70),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.ironGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.metallicWhite,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
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

class _ActivityImage extends StatelessWidget {
  const _ActivityImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      height: 164,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.72)),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BrokenImageFallback(),
      ),
    );
  }
}
