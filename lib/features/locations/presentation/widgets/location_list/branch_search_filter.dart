import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../data/branch_location_data.dart';

class BranchSearchFilter extends StatelessWidget {
  const BranchSearchFilter({
    super.key,
    required this.searchController,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final BranchFilter activeFilter;
  final ValueChanged<BranchFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BranchSearchField(searchController: searchController),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: BranchFilter.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final BranchFilter filter = BranchFilter.values[index];
              final bool isActive = filter == activeFilter;

              return _FilterChipButton(
                label: filter.label,
                isActive: isActive,
                onPressed: () => onFilterChanged(filter),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BranchSearchField extends StatelessWidget {
  const _BranchSearchField({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: TextField(
        controller: searchController,
        cursorColor: AppColors.gymGold,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AppColors.metallicWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.graphiteBlack.withValues(alpha: 0.92),
          hintText: 'Cari cabang atau area...',
          hintStyle: const TextStyle(
            color: AppColors.ironGray,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.gymGold,
            size: 24,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 58,
            minHeight: 64,
          ),
          contentPadding: const EdgeInsets.only(right: 18),
          border: _searchBorder(AppColors.gunmetal),
          enabledBorder: _searchBorder(AppColors.gunmetal),
          focusedBorder: _searchBorder(AppColors.gymGold),
        ),
      ),
    );
  }

  static OutlineInputBorder _searchBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isActive ? AppColors.gymGold : AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? AppColors.gymGold : AppColors.gunmetal,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.gymGold.withValues(alpha: 0.16),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? AppColors.blackCore : AppColors.silverGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
