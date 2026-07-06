import 'package:flutter/material.dart';

import '../../../../../core/colors.dart';
import '../../../../../core/icons/app_lucide_icons.dart';
import '../../../data/branch_location_data.dart';

// Search field and filter chips for the branch list.
class BranchSearchFilter extends StatelessWidget {
  const BranchSearchFilter({
    super.key,
    required this.searchController,
    required this.activeFilter,
    required this.filters,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final BranchFilter activeFilter;
  final List<BranchFilter> filters;
  final ValueChanged<BranchFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BranchSearchField(searchController: searchController),
        if (filters.length > 1) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final BranchFilter filter = filters[index];
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
      height: 58,
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
            AppLucideIcons.search,
            color: AppColors.gymGold,
            size: 21,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 54,
            minHeight: 58,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: searchController.clear,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.silverGray,
                  size: 18,
                ),
                tooltip: 'Bersihkan pencarian',
              );
            },
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
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
      borderRadius: BorderRadius.circular(18),
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
    // AnimatedContainer gives lightweight feedback when the active filter changes.
    return Semantics(
      selected: isActive,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gymGold : AppColors.graphiteBlack,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.gymGold : AppColors.gunmetal,
          ),
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
                    color: isActive
                        ? AppColors.blackCore
                        : AppColors.silverGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
