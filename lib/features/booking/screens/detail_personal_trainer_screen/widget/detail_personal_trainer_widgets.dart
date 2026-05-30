import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/booking_data.dart';

class PersonalTrainerDetailView extends StatelessWidget {
  const PersonalTrainerDetailView({
    super.key,
    required this.session,
    required this.selectedSlotIndex,
    required this.isExpanded,
    required this.sectionGap,
    required this.columnGap,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onMapPressed,
    required this.onBookingPressed,
    required this.onSlotSelected,
    required this.onResetSlot,
  });

  final PersonalTrainerSession session;
  final int selectedSlotIndex;
  final bool isExpanded;
  final double sectionGap;
  final double columnGap;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onMapPressed;
  final VoidCallback onBookingPressed;
  final ValueChanged<int> onSlotSelected;
  final VoidCallback onResetSlot;

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return _buildExpandedContent();
    }

    return _buildStackedContent();
  }

  Widget _buildStackedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonalTrainerTopBar(
          onBackPressed: onBackPressed,
          onSharePressed: onSharePressed,
        ),
        SizedBox(height: sectionGap),
        PersonalTrainerHeroCard(
          session: session,
          onMapPressed: onMapPressed,
          onBookingPressed: onBookingPressed,
        ),
        SizedBox(height: sectionGap),
        PersonalTrainerQuickGrid(session: session),
        SizedBox(height: sectionGap),
        PersonalTrainerInfoSection(session: session),
        SizedBox(height: sectionGap),
        PersonalTrainerSlotSection(
          slots: session.slots,
          selectedIndex: selectedSlotIndex,
          onSlotSelected: onSlotSelected,
          onResetPressed: onResetSlot,
        ),
        SizedBox(height: sectionGap),
        PersonalTrainerBenefitSection(benefits: session.benefits),
        SizedBox(height: sectionGap),
        PersonalTrainerCoachCard(session: session),
        SizedBox(height: sectionGap),
        PersonalTrainerActivityPreview(session: session),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonalTrainerTopBar(
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
                  PersonalTrainerHeroCard(
                    session: session,
                    onMapPressed: onMapPressed,
                    onBookingPressed: onBookingPressed,
                  ),
                  SizedBox(height: sectionGap),
                  PersonalTrainerQuickGrid(session: session),
                  SizedBox(height: sectionGap),
                  PersonalTrainerCoachCard(session: session),
                ],
              ),
            ),
            SizedBox(width: columnGap),
            Expanded(
              child: Column(
                children: [
                  PersonalTrainerInfoSection(session: session),
                  SizedBox(height: sectionGap),
                  PersonalTrainerSlotSection(
                    slots: session.slots,
                    selectedIndex: selectedSlotIndex,
                    onSlotSelected: onSlotSelected,
                    onResetPressed: onResetSlot,
                  ),
                  SizedBox(height: sectionGap),
                  PersonalTrainerBenefitSection(benefits: session.benefits),
                  SizedBox(height: sectionGap),
                  PersonalTrainerActivityPreview(session: session),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PersonalTrainerTopBar extends StatelessWidget {
  const PersonalTrainerTopBar({
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
                icon: Icons.chevron_left_rounded,
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
                      'Detail personal trainer',
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
                      'PT Session',
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
          icon: Icons.share_rounded,
          label: 'Bagikan',
          isPrimary: true,
          onPressed: onSharePressed,
        ),
      ],
    );
  }
}

class PersonalTrainerHeroCard extends StatelessWidget {
  const PersonalTrainerHeroCard({
    super.key,
    required this.session,
    required this.onMapPressed,
    required this.onBookingPressed,
  });

  final PersonalTrainerSession session;
  final VoidCallback onMapPressed;
  final VoidCallback onBookingPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.45)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: _HeroCover(imageUrl: session.coverImageUrl)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.blackCore.withValues(alpha: 0.18),
                    AppColors.blackCore.withValues(alpha: 0.76),
                    AppColors.blackCore.withValues(alpha: 0.94),
                  ],
                  stops: const [0, 0.56, 1],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BrandLogo(),
                  _StatusChip(label: 'Slot Tersedia'),
                ],
              ),
              const Spacer(),
              const Text(
                'PERSONAL TRAINER',
                style: TextStyle(
                  color: AppColors.paleGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                session.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 28,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                session.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.metallicWhite.withValues(alpha: 0.86),
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DetailActionButton(
                      label: 'Maps',
                      icon: Icons.navigation_rounded,
                      isPrimary: false,
                      onPressed: onMapPressed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailActionButton(
                      label: 'Booking',
                      icon: Icons.event_available_rounded,
                      isPrimary: true,
                      onPressed: onBookingPressed,
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

class PersonalTrainerQuickGrid extends StatelessWidget {
  const PersonalTrainerQuickGrid({super.key, required this.session});

  final PersonalTrainerSession session;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCard(
            icon: Icons.schedule_rounded,
            label: 'Jadwal',
            value: session.schedule,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickCard(
            icon: Icons.timer_rounded,
            label: 'Durasi',
            value: session.duration,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickCard(
            icon: Icons.location_on_rounded,
            label: 'Branch',
            value: session.branch,
          ),
        ),
      ],
    );
  }
}

class PersonalTrainerInfoSection extends StatelessWidget {
  const PersonalTrainerInfoSection({super.key, required this.session});

  final PersonalTrainerSession session;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Informasi Sesi',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.verified_rounded,
            label: 'Spesialisasi',
            value: session.specialization,
          ),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'Lokasi',
            value: session.location,
          ),
          _InfoRow(
            icon: Icons.verified_user_rounded,
            label: 'Jenis Program',
            value: session.programType,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class PersonalTrainerSlotSection extends StatelessWidget {
  const PersonalTrainerSlotSection({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.onSlotSelected,
    required this.onResetPressed,
  });

  final List<BookingSlot> slots;
  final int selectedIndex;
  final ValueChanged<int> onSlotSelected;
  final VoidCallback onResetPressed;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Pilih Slot',
      trailing: TextButton(
        onPressed: onResetPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gymGold,
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        child: const Text('Reset'),
      ),
      child: _SlotGrid(
        slots: slots,
        selectedIndex: selectedIndex,
        onSlotSelected: onSlotSelected,
      ),
    );
  }
}

class PersonalTrainerBenefitSection extends StatelessWidget {
  const PersonalTrainerBenefitSection({super.key, required this.benefits});

  final List<BookingBenefit> benefits;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Apa yang Kamu Dapat',
      child: _BenefitGrid(benefits: benefits),
    );
  }
}

class PersonalTrainerCoachCard extends StatelessWidget {
  const PersonalTrainerCoachCard({super.key, required this.session});

  final PersonalTrainerSession session;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Profil Coach',
      child: _CoachRow(
        name: session.name,
        role: session.role,
        rating: session.rating,
      ),
    );
  }
}

class PersonalTrainerActivityPreview extends StatelessWidget {
  const PersonalTrainerActivityPreview({super.key, required this.session});

  final PersonalTrainerSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview Aktivitas',
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
            itemCount: session.gallery.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _ActivityImage(imageUrl: session.gallery[index]);
            },
          ),
        ),
      ],
    );
  }
}

class PersonalTrainerBookingSheet extends StatelessWidget {
  const PersonalTrainerBookingSheet({
    super.key,
    required this.session,
    required this.selectedSlot,
    required this.onCancelPressed,
    required this.onConfirmPressed,
  });

  final PersonalTrainerSession session;
  final BookingSlot selectedSlot;
  final VoidCallback onCancelPressed;
  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.deepBlack.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(color: AppColors.gymGold.withValues(alpha: 0.28)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 60,
            offset: const Offset(0, -24),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.gunmetal,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Konfirmasi Booking',
              style: TextStyle(
                color: AppColors.metallicWhite,
                fontSize: 20,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cek kembali detail sesi sebelum booking dikonfirmasi.',
              style: TextStyle(
                color: AppColors.silverGray,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 16),
            _SheetSummaryRow(
              icon: Icons.verified_rounded,
              label: 'Sesi',
              value: session.name,
            ),
            const SizedBox(height: 10),
            _SheetSummaryRow(
              icon: Icons.schedule_rounded,
              label: 'Jadwal',
              value: selectedSlot.label,
            ),
            const SizedBox(height: 10),
            _SheetSummaryRow(
              icon: Icons.location_on_rounded,
              label: 'Lokasi',
              value: session.location,
            ),
            const SizedBox(height: 16),
            const _SheetAlert(
              text:
                  'Datang minimal 10 menit sebelum sesi. Booking dapat dilihat kembali dari menu Jadwal.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DetailActionButton(
                    label: 'Batal',
                    icon: Icons.close_rounded,
                    isPrimary: false,
                    onPressed: onCancelPressed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DetailActionButton(
                    label: 'Konfirmasi',
                    icon: Icons.verified_rounded,
                    isPrimary: true,
                    onPressed: onConfirmPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
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
        child: Icon(
          Icons.broken_image_rounded,
          color: AppColors.ironGray,
          size: 36,
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.28)),
      ),
      child: Image.asset('lib/assets/logo-1.jpeg', fit: BoxFit.cover),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.20)),
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
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
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
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? AppColors.gymGold
              : Colors.white.withValues(alpha: 0.06),
          foregroundColor: isPrimary
              ? AppColors.blackCore
              : AppColors.metallicWhite,
          side: BorderSide(
            color: isPrimary
                ? AppColors.gymGold
                : Colors.white.withValues(alpha: 0.10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
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
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gymGold.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, color: AppColors.gymGold, size: 17),
          ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.graphiteBlack.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gunmetal),
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.gymGold.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, color: AppColors.gymGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.ironGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
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

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selectedIndex,
    required this.onSlotSelected,
  });

  final List<BookingSlot> slots;
  final int selectedIndex;
  final ValueChanged<int> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.25,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final BookingSlot slot = slots[index];
        final bool isActive = selectedIndex == index;

        return OutlinedButton(
          onPressed: () => onSlotSelected(index),
          style: OutlinedButton.styleFrom(
            backgroundColor: isActive
                ? AppColors.gymGold.withValues(alpha: 0.14)
                : AppColors.steelBlack.withValues(alpha: 0.72),
            foregroundColor: AppColors.metallicWhite,
            side: BorderSide(
              color: isActive
                  ? AppColors.gymGold.withValues(alpha: 0.35)
                  : AppColors.gunmetal.withValues(alpha: 0.72),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slot.day,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? AppColors.gymGold : AppColors.ironGray,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BenefitGrid extends StatelessWidget {
  const _BenefitGrid({required this.benefits});

  final List<BookingBenefit> benefits;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: benefits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.42,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final BookingBenefit benefit = benefits[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.steelBlack.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gunmetal.withValues(alpha: 0.72),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(benefit.icon, color: AppColors.gymGold, size: 20),
              const Spacer(),
              Text(
                benefit.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CoachRow extends StatelessWidget {
  const _CoachRow({
    required this.name,
    required this.role,
    required this.rating,
  });

  final String name;
  final String role;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gymGold.withValues(alpha: 0.18),
            ),
          ),
          child: const Icon(
            Icons.how_to_reg_rounded,
            color: AppColors.gymGold,
            size: 22,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                role,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _RatingPill(rating: rating),
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gymGold, size: 13),
          const SizedBox(width: 5),
          Text(
            rating,
            style: const TextStyle(
              color: AppColors.gymGold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BrokenImageFallback(),
      ),
    );
  }
}

class _SheetSummaryRow extends StatelessWidget {
  const _SheetSummaryRow({
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
        color: AppColors.steelBlack.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.gymGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.ironGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.metallicWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _SheetAlert extends StatelessWidget {
  const _SheetAlert({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gymGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: AppColors.paleGold, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.paleGold,
                fontSize: 11,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
