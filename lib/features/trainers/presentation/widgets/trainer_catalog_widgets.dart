import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/repositories/trainer_repository.dart';

/// Header katalog trainer menampilkan jumlah data yang sudah dipetakan repository.
class TrainerCatalogHeader extends StatelessWidget {
  const TrainerCatalogHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Personal Trainer',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.gymGold.withValues(alpha: 0.18),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count Trainer',
            style: const TextStyle(
              color: AppColors.gymGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu ringkasan trainer untuk list. Semua data yang tampil berasal dari
/// TrainerProfile sehingga widget ini tidak perlu mengenal DTO backend.
class TrainerProfileCard extends StatelessWidget {
  const TrainerProfileCard({
    super.key,
    required this.trainer,
    required this.onDetailPressed,
  });

  final TrainerProfile trainer;
  final VoidCallback onDetailPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: trainer.rating == null
              ? AppColors.gunmetal
              : AppColors.gymGold.withValues(alpha: 0.42),
        ),
        boxShadow: trainer.rating == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.gymGold.withValues(alpha: 0.05),
                  blurRadius: 18,
                ),
              ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: _NetworkCover(imageUrl: trainer.coverImageUrl),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blackCore.withValues(alpha: 0.92),
                    AppColors.blackCore.withValues(alpha: 0.72),
                    AppColors.blackCore.withValues(alpha: 0.90),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TrainerCardHeader(trainer: trainer),
                const SizedBox(height: 14),
                Text(
                  trainer.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.metallicWhite.withValues(alpha: 0.84),
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetaBox(
                        icon: AppLucideIcons.mapPin,
                        label: 'Cabang',
                        value: trainer.branch,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetaBox(
                        icon: AppLucideIcons.timer,
                        label: 'Durasi',
                        value: trainer.duration,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ChipWrap(
                  chips: [
                    trainer.specialization,
                    trainer.scheduleLabel,
                    trainer.programType,
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: onDetailPressed,
                    icon: const Icon(Icons.info_rounded, size: 16),
                    label: const Text(
                      'Lihat detail',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.gymGold,
                      foregroundColor: AppColors.blackCore,
                      side: const BorderSide(color: AppColors.gymGold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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
}

/// Status list disatukan agar loading, empty, dan failure punya ukuran minimum
/// yang konsisten di dalam scroll view home.
class TrainerStatusCard extends StatelessWidget {
  const TrainerStatusCard.loading({super.key})
    : message = 'Memuat trainer tersedia...',
      onRetryPressed = null,
      isEmptyState = false;

  const TrainerStatusCard.failure({
    super.key,
    required this.message,
    required this.onRetryPressed,
  }) : isEmptyState = false;

  const TrainerStatusCard.empty({super.key})
    : message = 'Belum ada trainer aktif yang tersedia.',
      onRetryPressed = null,
      isEmptyState = true;

  final String message;
  final VoidCallback? onRetryPressed;
  final bool isEmptyState;

  @override
  Widget build(BuildContext context) {
    final retryAction = onRetryPressed;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Row(
        children: [
          if (retryAction == null && !isEmptyState)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.gymGold,
              ),
            )
          else
            Icon(
              isEmptyState ? Icons.person_search_rounded : Icons.info_rounded,
              color: AppColors.gymGold,
              size: 22,
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
    );
  }
}

class _TrainerCardHeader extends StatelessWidget {
  const _TrainerCardHeader({required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.gymGold.withValues(alpha: 0.18),
            ),
          ),
          child: const Icon(
            AppLucideIcons.userPlus,
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
                trainer.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                trainer.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _RatingChip(rating: trainer.ratingLabel),
      ],
    );
  }
}

class _NetworkCover extends StatelessWidget {
  const _NetworkCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // Gambar katalog boleh gagal tanpa merusak kartu; fallback tetap menjaga
    // kontras teks di atas gradient.
    return Opacity(
      opacity: 0.22,
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
        child: Icon(
          Icons.broken_image_rounded,
          color: AppColors.ironGray,
          size: 34,
        ),
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
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gymGold, size: 14),
          const SizedBox(width: 5),
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

class _MetaBox extends StatelessWidget {
  const _MetaBox({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.steelBlack.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gymGold, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.silverGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.chips});

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(chips.length, (index) {
        final isActive = index == 0;

        return Container(
          constraints: const BoxConstraints(minHeight: 30),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.gymGold.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? AppColors.gymGold.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Text(
            chips[index],
            style: TextStyle(
              color: isActive ? AppColors.gymGold : AppColors.silverGray,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }),
    );
  }
}
