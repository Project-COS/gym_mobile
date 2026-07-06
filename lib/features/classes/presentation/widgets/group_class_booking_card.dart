import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../data/class_data.dart';

// Compact class catalog card used by the booking screen list/grid.
class GroupClassBookingCard extends StatelessWidget {
  const GroupClassBookingCard({
    super.key,
    required this.session,
    required this.onDetailPressed,
    required this.onBookingPressed,
  });

  final GroupClassSession session;
  final VoidCallback onDetailPressed;
  final VoidCallback onBookingPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: session.isFeatured
              ? AppColors.gymGold.withValues(alpha: 0.48)
              : AppColors.gunmetal,
        ),
        boxShadow: session.isFeatured
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
          Positioned.fill(
            child: _NetworkCover(imageUrl: session.coverImageUrl),
          ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 188),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClassHeader(session: session),
                  const SizedBox(height: 36),
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
                          icon: Icons.schedule_rounded,
                          label: 'Durasi',
                          value: session.duration,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ChipWrap(chips: session.tags),
                  const SizedBox(height: 14),
                  _ActionRow(
                    onDetailPressed: onDetailPressed,
                    onBookingPressed: onBookingPressed,
                  ),
                ],
              ),
            ),
          ),
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
        // Broken CMS images should degrade into a stable card background.
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

class _ClassHeader extends StatelessWidget {
  const _ClassHeader({required this.session});

  final GroupClassSession session;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 19,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                session.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.metallicWhite.withValues(alpha: 0.88),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _SlotStatusChip(label: session.slotLabel),
      ],
    );
  }
}

class _SlotStatusChip extends StatelessWidget {
  const _SlotStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.success,
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
        color: AppColors.blackCore.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
    required this.onDetailPressed,
    required this.onBookingPressed,
  });

  final VoidCallback onDetailPressed;
  final VoidCallback onBookingPressed;

  @override
  Widget build(BuildContext context) {
    // Detail and booking actions are separated because booking can be started
    // directly from the catalog without opening the full detail screen.
    return Row(
      children: [
        Expanded(
          child: _CardActionButton(
            label: 'Detail',
            icon: Icons.info_rounded,
            isPrimary: false,
            onPressed: onDetailPressed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _CardActionButton(
            label: 'Booking',
            icon: Icons.event_available_rounded,
            isPrimary: true,
            onPressed: onBookingPressed,
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
