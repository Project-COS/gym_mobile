import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/branch_location_data.dart';

class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.branch,
    required this.onDetailPressed,
    required this.onMapPressed,
  });

  final BranchLocation branch;
  final VoidCallback onDetailPressed;
  final VoidCallback onMapPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: branch.isFeatured
              ? AppColors.gymGold.withValues(alpha: 0.46)
              : AppColors.gunmetal,
        ),
        boxShadow: branch.isFeatured
            ? [
                BoxShadow(
                  color: AppColors.gymGold.withValues(alpha: 0.06),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BranchCover(imageUrl: branch.imageUrl, semanticLabel: branch.name),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _BranchHeader(branch: branch),
                const SizedBox(height: 14),
                _BranchMetaGrid(branch: branch),
                const SizedBox(height: 14),
                _FacilityChips(facilities: branch.facilities.take(3).toList()),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _BranchActionButton(
                        label: 'Detail',
                        icon: Icons.info_rounded,
                        isPrimary: false,
                        onPressed: onDetailPressed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BranchActionButton(
                        label: 'Maps',
                        icon: Icons.location_on_rounded,
                        isPrimary: true,
                        onPressed: onMapPressed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchCover extends StatelessWidget {
  const _BranchCover({required this.imageUrl, required this.semanticLabel});

  final String imageUrl;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            semanticLabel: semanticLabel,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return const ColoredBox(
                color: AppColors.steelBlack,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.gymGold,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (_, _, _) => const ColoredBox(
              color: AppColors.steelBlack,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  color: AppColors.silverGray,
                  size: 26,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.blackCore.withValues(alpha: 0.46),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchHeader extends StatelessWidget {
  const _BranchHeader({required this.branch});

  final BranchLocation branch;

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
            Icons.apartment_rounded,
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
                branch.name,
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
                branch.address,
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
        const _OpenStatusChip(),
      ],
    );
  }
}

class _OpenStatusChip extends StatelessWidget {
  const _OpenStatusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: AppColors.success),
          SizedBox(width: 6),
          Text(
            'Open',
            style: TextStyle(
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

class _BranchMetaGrid extends StatelessWidget {
  const _BranchMetaGrid({required this.branch});

  final BranchLocation branch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetaBox(
            icon: Icons.schedule_rounded,
            label: 'Jam Buka',
            value: branch.hours,
          ),
        ),
      ],
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

class _FacilityChips extends StatelessWidget {
  const _FacilityChips({required this.facilities});

  final List<BranchFacility> facilities;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: facilities.map((facility) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(facility.icon, color: AppColors.gymGold, size: 13),
                const SizedBox(width: 6),
                Text(
                  facility.name,
                  style: const TextStyle(
                    color: AppColors.silverGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BranchActionButton extends StatelessWidget {
  const _BranchActionButton({
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
