import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/profile_data.dart';
import '../../data/repositories/profile_repository.dart';
import '../cubit/profile_cubit.dart';
import 'edit_profile_screen.dart';

// Profile tab screen. Data is lazy-loaded only when the Home tab becomes active.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isActive = false});

  final bool isActive;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileRepository? _repository;
  ProfileCubit? _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final repository = context.read<ProfileRepository>();

    if (_repository != repository || _cubit == null) {
      // Recreate the route-scoped Cubit if the injected repository changes.
      _cubit?.close();
      _repository = repository;
      _cubit = ProfileCubit(repository: repository);
    }

    if (widget.isActive) {
      _fetchProfileIfNeeded();
    }
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _fetchProfileIfNeeded();
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  void _fetchProfileIfNeeded() {
    final cubit = _cubit;

    // IndexedStack keeps tabs alive, so only the initial state should auto-load.
    if (cubit == null || cubit.state.status != ProfileLoadStatus.initial) {
      return;
    }

    cubit.fetchProfile();
  }

  Future<void> _refreshProfile() {
    return _cubit?.fetchProfile(forceRefresh: true) ?? Future<void>.value();
  }

  void _openEditProfile(MemberProfile profile) {
    final cubit = _cubit;

    if (cubit == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          // Share the same Cubit so successful edits update this screen immediately.
          value: cubit,
          child: EditProfileScreen(profile: profile),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;

    if (cubit == null) {
      return const _ProfileStatusCard.loading(message: 'Memuat profile...');
    }

    return Container(
      color: AppColors.blackCore,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spec = ProfileLayoutSpec.fromWidth(constraints.maxWidth);

            return RefreshIndicator(
              color: AppColors.gymGold,
              backgroundColor: AppColors.graphiteBlack,
              onRefresh: _refreshProfile,
              child: BlocBuilder<ProfileCubit, ProfileState>(
                bloc: cubit,
                builder: (context, state) {
                  return SingleChildScrollView(
                    // Required so pull-to-refresh works even for short states.
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: spec.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: spec.maxContentWidth,
                        ),
                        child: _buildContent(spec, state),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ProfileLayoutSpec spec, ProfileState state) {
    final profile = state.profile;

    if (state.isLoading && profile == null) {
      return const _ProfileStatusCard.loading(message: 'Memuat profile...');
    }

    if (state.status == ProfileLoadStatus.failure && profile == null) {
      return _ProfileStatusCard.failure(
        message:
            state.errorMessage ??
            'Profile belum bisa dimuat. Silakan coba kembali.',
        onRetryPressed: () => _cubit?.fetchProfile(forceRefresh: true),
      );
    }

    if (profile == null) {
      return const _ProfileStatusCard.empty(
        title: 'Profile belum tersedia',
        message: 'Tarik layar ke bawah untuk memuat ulang data profile.',
      );
    }

    final profileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileTopBar(onEditPressed: () => _openEditProfile(profile)),
        SizedBox(height: spec.sectionGap),
        _ProfileHeroCard(profile: profile),
        if (state.isLoading) ...[
          const SizedBox(height: 14),
          const LinearProgressIndicator(
            color: AppColors.gymGold,
            backgroundColor: AppColors.gunmetal,
          ),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: 14),
          _ProfileInlineNotice(message: state.errorMessage!),
        ],
        SizedBox(height: spec.sectionGap),
        _ProfileInfoCard(profile: profile),
        SizedBox(height: spec.sectionGap),
        _ProfileMembershipCard(profile: profile),
      ],
    );

    if (!spec.isExpanded) {
      // Mobile and tablet use one vertical content flow.
      return profileContent;
    }

    // Wide screens split identity and detailed membership data into columns.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileTopBar(onEditPressed: () => _openEditProfile(profile)),
              SizedBox(height: spec.sectionGap),
              _ProfileHeroCard(profile: profile),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 14),
                _ProfileInlineNotice(message: state.errorMessage!),
              ],
            ],
          ),
        ),
        SizedBox(width: spec.columnGap),
        Expanded(
          child: Column(
            children: [
              _ProfileInfoCard(profile: profile),
              SizedBox(height: spec.sectionGap),
              _ProfileMembershipCard(profile: profile),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onEditPressed});

  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Tooltip(
          message: 'Edit profile',
          child: IconButton.filled(
            onPressed: onEditPressed,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gymGold,
              foregroundColor: AppColors.blackCore,
            ),
            icon: const Icon(Icons.edit_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
        boxShadow: [
          BoxShadow(
            color: AppColors.gymGold.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.steelBlack,
              border: Border.all(color: AppColors.gymGold, width: 3),
            ),
            child: Text(
              _profileInitials(profile.name),
              style: const TextStyle(
                color: AppColors.gymGold,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.memberCode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gymGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.gymGold.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AppLucideIcons.badgeCheck,
                  color: AppColors.gymGold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    profile.badgeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gymGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Data Member',
      child: Column(
        children: [
          _ProfileInfoRow(
            icon: AppLucideIcons.person,
            label: 'Member Code',
            value: profile.memberCode,
          ),
          const _ProfileDivider(),
          _ProfileInfoRow(
            icon: AppLucideIcons.mail,
            label: 'Email',
            value: _displayValue(profile.email),
          ),
          const _ProfileDivider(),
          _ProfileInfoRow(
            icon: AppLucideIcons.phone,
            label: 'Phone',
            value: _displayValue(profile.phone),
          ),
          const _ProfileDivider(),
          _ProfileInfoRow(
            icon: AppLucideIcons.building,
            label: 'Company',
            value: profile.companyName,
          ),
        ],
      ),
    );
  }
}

class _ProfileMembershipCard extends StatelessWidget {
  const _ProfileMembershipCard({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: 'Membership',
      child: Column(
        children: [
          _ProfileInfoRow(
            icon: AppLucideIcons.badgeCheck,
            label: profile.membershipPlanName,
            value: profile.membershipStatusLabel,
            valueColor: profile.hasActiveMembership
                ? AppColors.success
                : AppColors.warning,
          ),
          const _ProfileDivider(),
          _ProfileInfoRow(
            icon: AppLucideIcons.calendar,
            label: 'Berlaku Hingga',
            value: profile.membershipExpiryLabel,
          ),
          const _ProfileDivider(),
          _ProfileInfoRow(
            icon: AppLucideIcons.mapPin,
            label: 'Access',
            value: profile.accessLabel,
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.gymGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.gymGold, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor ?? AppColors.metallicWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: AppColors.gunmetal),
    );
  }
}

class _ProfileInlineNotice extends StatelessWidget {
  const _ProfileInlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.warning,
          fontSize: 12,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProfileStatusCard extends StatelessWidget {
  const _ProfileStatusCard.loading({required this.message})
    : title = 'Memuat data',
      icon = Icons.person_rounded,
      showProgress = true,
      onRetryPressed = null;

  const _ProfileStatusCard.failure({
    required this.message,
    required this.onRetryPressed,
  }) : title = 'Data belum bisa dimuat',
       icon = Icons.info_rounded,
       showProgress = false;

  const _ProfileStatusCard.empty({required this.title, required this.message})
    : icon = Icons.person_search_rounded,
      showProgress = false,
      onRetryPressed = null;

  final String title;
  final String message;
  final IconData icon;
  final bool showProgress;
  final VoidCallback? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final retryAction = onRetryPressed;

    return Container(
      color: AppColors.blackCore,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420, minHeight: 220),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.graphiteBlack,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gunmetal),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.gymGold, size: 36),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.metallicWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 12,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showProgress) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  color: AppColors.gymGold,
                  strokeWidth: 2.6,
                ),
              ],
              if (retryAction != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: retryAction,
                  child: const Text(
                    'Coba lagi',
                    style: TextStyle(
                      color: AppColors.gymGold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileLayoutSpec {
  const ProfileLayoutSpec({
    required this.isExpanded,
    required this.maxContentWidth,
    required this.pagePadding,
    required this.sectionGap,
    required this.columnGap,
  });

  final bool isExpanded;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final double sectionGap;
  final double columnGap;

  factory ProfileLayoutSpec.fromWidth(double width) {
    // Mirrors the shared breakpoints from AGENTS.md.
    if (width >= 840) {
      return const ProfileLayoutSpec(
        isExpanded: true,
        maxContentWidth: 1040,
        pagePadding: EdgeInsets.fromLTRB(40, 32, 40, 32),
        sectionGap: 20,
        columnGap: 24,
      );
    }

    if (width >= 600) {
      return const ProfileLayoutSpec(
        isExpanded: false,
        maxContentWidth: 640,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
        columnGap: 0,
      );
    }

    return const ProfileLayoutSpec(
      isExpanded: false,
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 28, 20, 24),
      sectionGap: 18,
      columnGap: 0,
    );
  }
}

String _profileInitials(String name) {
  // Use text initials instead of a remote avatar so profile never depends on media.
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty) {
    return 'M';
  }

  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }

  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

String _displayValue(String value) {
  final normalizedValue = value.trim();
  return normalizedValue.isEmpty ? 'Belum tersedia' : normalizedValue;
}
