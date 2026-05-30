import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../branch_location_data.dart';

class BranchFacilitySection extends StatelessWidget {
  const BranchFacilitySection({super.key, required this.facilities});

  final List<BranchFacility> facilities;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Fasilitas',
      actionLabel: 'Lengkap',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _sectionCardDecoration(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 520;

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: facilities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isWide ? 2.6 : 1.85,
              ),
              itemBuilder: (context, index) {
                final BranchFacility facility = facilities[index];

                return _FacilityItem(facility: facility);
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.child,
    this.actionLabel,
  });

  final String title;
  final Widget child;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final String? actionLabel = this.actionLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (actionLabel != null)
              Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.gymGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _FacilityItem extends StatelessWidget {
  const _FacilityItem({required this.facility});

  final BranchFacility facility;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.steelBlack.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gunmetal.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(facility.icon, color: AppColors.gymGold, size: 20),
          const SizedBox(height: 10),
          Text(
            facility.name,
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
  }
}

BoxDecoration _sectionCardDecoration() {
  return BoxDecoration(
    color: AppColors.graphiteBlack.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.gunmetal),
  );
}
