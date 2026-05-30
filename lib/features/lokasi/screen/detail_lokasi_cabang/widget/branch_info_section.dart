import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../branch_location_data.dart';

class BranchInfoSection extends StatelessWidget {
  const BranchInfoSection({super.key, required this.branch});

  final BranchLocation branch;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Informasi Branch',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _sectionCardDecoration(),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: 'Alamat Lengkap',
              value: branch.address,
            ),
            Divider(
              height: 24,
              color: AppColors.gunmetal.withValues(alpha: 0.72),
            ),
            _InfoRow(
              icon: Icons.phone_rounded,
              label: 'Kontak',
              value: branch.phone,
            ),
            Divider(
              height: 24,
              color: AppColors.gunmetal.withValues(alpha: 0.72),
            ),
            _InfoRow(
              icon: Icons.verified_rounded,
              label: 'Akses Membership',
              value: branch.access,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.metallicWhite,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

BoxDecoration _sectionCardDecoration() {
  return BoxDecoration(
    color: AppColors.graphiteBlack.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.gunmetal),
  );
}
