import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';

// Top actions for the branch detail route.
class BranchDetailTopBar extends StatelessWidget {
  const BranchDetailTopBar({
    super.key,
    required this.onBackPressed,
    required this.onSharePressed,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _TopBarActionButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Kembali',
                foregroundColor: AppColors.metallicWhite,
                backgroundColor: AppColors.graphiteBlack,
                borderColor: AppColors.gunmetal,
                onPressed: onBackPressed,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail lokasi',
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
                      'Branch Detail',
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
        _TopBarActionButton(
          icon: Icons.share_rounded,
          tooltip: 'Bagikan branch',
          foregroundColor: AppColors.blackCore,
          backgroundColor: AppColors.gymGold,
          borderColor: AppColors.gymGold,
          onPressed: onSharePressed,
        ),
      ],
    );
  }
}

class _TopBarActionButton extends StatelessWidget {
  const _TopBarActionButton({
    required this.icon,
    required this.tooltip,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: backgroundColor == AppColors.gymGold
                ? [
                    BoxShadow(
                      color: AppColors.gymGold.withValues(alpha: 0.16),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: foregroundColor, size: 22),
        ),
      ),
    );
  }
}
