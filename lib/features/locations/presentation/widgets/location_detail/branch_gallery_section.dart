import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/branch_location_data.dart';

// Horizontal gallery for branch images returned by the locations API.
class BranchGallerySection extends StatelessWidget {
  const BranchGallerySection({super.key, required this.images});

  final List<BranchGalleryImage> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galeri Cabang',
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
            itemCount: images.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _BranchGalleryImageCard(image: images[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _BranchGalleryImageCard extends StatelessWidget {
  const _BranchGalleryImageCard({required this.image});

  final BranchGalleryImage image;

  @override
  Widget build(BuildContext context) {
    final String? caption = image.caption;

    return Container(
      width: 252,
      height: 164,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gymGold.withValues(alpha: 0.18)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.imageUrl,
            semanticLabel: image.semanticLabel,
            fit: BoxFit.cover,
            // Gallery cards should remain stable when one remote image fails.
            errorBuilder: (_, _, _) => const _BrokenImageFallback(),
          ),
          if (caption != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.blackCore.withValues(alpha: 0.74),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
                  child: Text(
                    caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.metallicWhite,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
