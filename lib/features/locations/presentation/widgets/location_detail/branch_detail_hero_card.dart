import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/branch_location_data.dart';

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
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.48)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gymGold.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        ],
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
                  const _OpenNowChip(),
                ],
              ),
              const Spacer(),
              const Text(
                'DO GYM BRANCH',
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
                      icon: Icons.phone_rounded,
                      isPrimary: false,
                      onPressed: onCallPressed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroActionButton(
                      label: 'Buka Maps',
                      icon: Icons.navigation_rounded,
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
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.steelBlack,
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class _OpenNowChip extends StatelessWidget {
  const _OpenNowChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.24)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: AppColors.success),
          SizedBox(width: 7),
          Text(
            'Open Now',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
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
