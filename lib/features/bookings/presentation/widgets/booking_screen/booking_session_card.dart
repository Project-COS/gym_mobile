import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/booking_data.dart';

class PersonalTrainerBookingCard extends StatelessWidget {
  const PersonalTrainerBookingCard({
    super.key,
    required this.session,
    required this.onDetailPressed,
    required this.onBookingPressed,
  });

  final PersonalTrainerSession session;
  final VoidCallback onDetailPressed;
  final VoidCallback onBookingPressed;

  @override
  Widget build(BuildContext context) {
    return _BookingCardShell(
      isFeatured: session.isFeatured,
      minHeight: null,
      imageUrl: session.isFeatured ? session.coverImageUrl : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SessionHeader(
            icon: session.icon,
            title: session.name,
            subtitle: session.subtitle,
            trailing: _RatingChip(rating: session.rating),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetaBox(
                  icon: Icons.location_on_rounded,
                  label: 'Branch',
                  value: session.branch,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetaBox(
                  icon: Icons.timer_rounded,
                  label: 'Durasi',
                  value: session.duration,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ChipWrap(
            chips: session.slots.take(3).map((slot) => slot.label).toList(),
          ),
          const SizedBox(height: 14),
          _ActionRow(
            primaryLabel: 'Booking',
            secondaryLabel: 'Detail',
            onPrimaryPressed: onBookingPressed,
            onSecondaryPressed: onDetailPressed,
          ),
        ],
      ),
    );
  }
}

class _BookingCardShell extends StatelessWidget {
  const _BookingCardShell({
    required this.isFeatured,
    required this.minHeight,
    required this.imageUrl,
    required this.child,
  });

  final bool isFeatured;
  final double? minHeight;
  final String? imageUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      constraints: minHeight == null
          ? const BoxConstraints()
          : BoxConstraints(minHeight: minHeight!),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isFeatured
              ? AppColors.gymGold.withValues(alpha: 0.48)
              : AppColors.gunmetal,
        ),
        boxShadow: isFeatured
            ? [
                BoxShadow(
                  color: AppColors.gymGold.withValues(alpha: 0.06),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (imageUrl != null)
            Positioned.fill(child: _NetworkCover(imageUrl: imageUrl!)),
          if (imageUrl != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blackCore.withValues(alpha: 0.92),
                      AppColors.blackCore.withValues(alpha: 0.72),
                      AppColors.blackCore.withValues(alpha: 0.86),
                    ],
                  ),
                ),
              ),
            ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _NetworkCover extends StatelessWidget {
  const _NetworkCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
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

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

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
          child: Icon(icon, color: AppColors.gymGold, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
                subtitle,
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
        trailing,
      ],
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
        final bool isActive = index == 0;

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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CardActionButton(
            label: secondaryLabel,
            icon: Icons.info_rounded,
            isPrimary: false,
            onPressed: onSecondaryPressed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CardActionButton(
            label: primaryLabel,
            icon: Icons.event_available_rounded,
            isPrimary: true,
            onPressed: onPrimaryPressed,
          ),
        ),
      ],
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
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
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
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
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
