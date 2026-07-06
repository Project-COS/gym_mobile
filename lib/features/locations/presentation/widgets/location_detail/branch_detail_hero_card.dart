import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../../../core/icons/app_lucide_icons.dart';
import '../../../data/branch_location_data.dart';

// Hero card for the selected branch. Call and map actions are owned by the screen.
class BranchDetailHeroCard extends StatelessWidget {
  const BranchDetailHeroCard({
    super.key,
    required this.branch,
    required this.onCallPressed,
    required this.onMapPressed,
  });

  final BranchLocation branch;
  final VoidCallback onCallPressed;
  final VoidCallback onMapPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.30)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: _HeroCover(imageUrl: branch.imageUrl)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.blackCore.withValues(alpha: 0.18),
                    AppColors.blackCore.withValues(alpha: 0.68),
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
                  Container(
                    width: 52,
                    height: 52,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.gymGold.withValues(alpha: 0.36),
                      ),
                    ),
                    child: Image.asset(
                      'lib/assets/logo-1.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  _BranchOpenStatusChip(branch: branch),
                ],
              ),
              const Spacer(),
              const Text(
                'DO GYM CABANG',
                style: TextStyle(
                  color: AppColors.paleGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                branch.name,
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
                branch.address,
                maxLines: 2,
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
                    child: _HeroActionButton(
                      label: 'Telepon',
                      icon: AppLucideIcons.phone,
                      isPrimary: false,
                      onPressed: onCallPressed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroActionButton(
                      label: 'Maps',
                      icon: AppLucideIcons.navigation,
                      isPrimary: true,
                      onPressed: onMapPressed,
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

class _HeroCover extends StatelessWidget {
  const _HeroCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.42,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        // Hero image is remote media; fall back to a neutral surface on failure.
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.steelBlack,
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BranchOpenStatusChip extends StatelessWidget {
  const _BranchOpenStatusChip({required this.branch});

  final BranchLocation branch;

  Color get _statusColor {
    if (!branch.hasKnownOpenStatus) {
      return AppColors.warning;
    }

    return branch.isOpen ? AppColors.success : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: statusColor),
          const SizedBox(width: 7),
          Text(
            branch.openStatusLabel,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
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
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? AppColors.gymGold
              : AppColors.steelBlack.withValues(alpha: 0.78),
          foregroundColor: isPrimary
              ? AppColors.blackCore
              : AppColors.metallicWhite,
          side: BorderSide(
            color: isPrimary
                ? AppColors.gymGold
                : Colors.white.withValues(alpha: 0.10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
