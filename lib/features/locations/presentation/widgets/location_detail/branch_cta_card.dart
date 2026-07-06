import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../../../core/icons/app_lucide_icons.dart';
import '../../../data/branch_location_data.dart';

// Branch detail CTA. Current callbacks are injected so future check-in/booking
// flows can be wired without changing this presentational widget.
class BranchCtaCard extends StatelessWidget {
  const BranchCtaCard({
    super.key,
    required this.branch,
    required this.onCheckInPressed,
    required this.onBookingPressed,
  });

  final BranchLocation branch;
  final VoidCallback onCheckInPressed;
  final VoidCallback onBookingPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Siap latihan di cabang ini?',
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 18,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Datang langsung ke ${branch.name} atau booking kelas supaya slot latihan kamu lebih aman.',
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CtaButton(
                  label: 'Check-in',
                  icon: AppLucideIcons.qrScanner,
                  isPrimary: false,
                  onPressed: onCheckInPressed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CtaButton(
                  label: 'Booking',
                  icon: AppLucideIcons.calendar,
                  isPrimary: true,
                  onPressed: onBookingPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
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
          backgroundColor: isPrimary ? AppColors.gymGold : AppColors.steelBlack,
          foregroundColor: isPrimary
              ? AppColors.blackCore
              : AppColors.metallicWhite,
          side: BorderSide(
            color: isPrimary ? AppColors.gymGold : AppColors.gunmetal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
