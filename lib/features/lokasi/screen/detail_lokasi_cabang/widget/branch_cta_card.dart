import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../branch_location_data.dart';

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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.24)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.graphiteBlack,
            AppColors.steelBlack,
            AppColors.gymGold.withValues(alpha: 0.22),
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -40,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.gymGold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Siap latihan di branch ini?',
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
                      icon: Icons.qr_code_scanner_rounded,
                      isPrimary: false,
                      onPressed: onCheckInPressed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CtaButton(
                      label: 'Booking',
                      icon: Icons.calendar_month_rounded,
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
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
