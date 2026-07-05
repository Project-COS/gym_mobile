import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors.dart';
import '../../../../core/icons/app_lucide_icons.dart';
import '../../data/profile_data.dart';
import '../cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final MemberProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    final success = await context.read<ProfileCubit>().updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    final errorMessage = context.read<ProfileCubit>().state.formErrorMessage;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackCore,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final spec = _EditProfileLayoutSpec.fromWidth(
                  constraints.maxWidth,
                );

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: spec.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: spec.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _EditProfileTopBar(),
                          SizedBox(height: spec.sectionGap),
                          _EditProfilePreviewCard(
                            nameController: _nameController,
                            memberCode: widget.profile.memberCode,
                            badgeLabel: widget.profile.badgeLabel,
                          ),
                          SizedBox(height: spec.sectionGap),
                          _EditProfileFormCard(
                            formKey: _formKey,
                            nameController: _nameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            errorMessage: state.formErrorMessage,
                            isSubmitting: state.isUpdating,
                            onSubmit: _submitProfile,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EditProfileTopBar extends StatelessWidget {
  const _EditProfileTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.graphiteBlack,
            foregroundColor: AppColors.metallicWhite,
          ),
          icon: const Icon(AppLucideIcons.chevronLeft, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditProfilePreviewCard extends StatefulWidget {
  const _EditProfilePreviewCard({
    required this.nameController,
    required this.memberCode,
    required this.badgeLabel,
  });

  final TextEditingController nameController;
  final String memberCode;
  final String badgeLabel;

  @override
  State<_EditProfilePreviewCard> createState() =>
      _EditProfilePreviewCardState();
}

class _EditProfilePreviewCardState extends State<_EditProfilePreviewCard> {
  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_handleNameChanged);
  }

  @override
  void didUpdateWidget(covariant _EditProfilePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.nameController != widget.nameController) {
      oldWidget.nameController.removeListener(_handleNameChanged);
      widget.nameController.addListener(_handleNameChanged);
    }
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_handleNameChanged);
    super.dispose();
  }

  void _handleNameChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.nameController.text.trim().isEmpty
        ? 'Member'
        : widget.nameController.text.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.steelBlack,
              border: Border.all(color: AppColors.gymGold, width: 3),
            ),
            child: Text(
              _profileInitials(name),
              style: const TextStyle(
                color: AppColors.gymGold,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.metallicWhite,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.memberCode,
            style: const TextStyle(
              color: AppColors.silverGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.badgeLabel,
            style: const TextStyle(
              color: AppColors.gymGold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileFormCard extends StatelessWidget {
  const _EditProfileFormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.errorMessage,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? errorMessage;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.graphiteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gunmetal),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Member',
              style: TextStyle(
                color: AppColors.metallicWhite,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: nameController,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: AppColors.metallicWhite,
                fontWeight: FontWeight.w700,
              ),
              decoration: _inputDecoration(
                label: 'Nama Lengkap',
                icon: AppLucideIcons.person,
              ),
              validator: (value) {
                if ((value ?? '').trim().length < 2) {
                  return 'Nama minimal 2 karakter.';
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              enabled: !isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: AppColors.metallicWhite,
                fontWeight: FontWeight.w700,
              ),
              decoration: _inputDecoration(
                label: 'Email',
                icon: AppLucideIcons.mail,
              ),
              validator: (value) {
                final email = (value ?? '').trim().toLowerCase();

                if (!_emailPattern.hasMatch(email)) {
                  return 'Masukkan email yang valid.';
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phoneController,
              enabled: !isSubmitting,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                color: AppColors.metallicWhite,
                fontWeight: FontWeight.w700,
              ),
              decoration: _inputDecoration(
                label: 'Nomor Telepon',
                icon: AppLucideIcons.phone,
              ),
              validator: (value) {
                final digitCount = RegExp(
                  r'\d',
                ).allMatches((value ?? '').trim()).length;

                if (digitCount < 10) {
                  return 'Nomor telepon minimal 10 digit.';
                }

                return null;
              },
              onFieldSubmitted: (_) {
                if (!isSubmitting) {
                  onSubmit();
                }
              },
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.metallicWhite,
                      side: const BorderSide(color: AppColors.gunmetal),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gymGold,
                      foregroundColor: AppColors.blackCore,
                      disabledBackgroundColor: AppColors.gunmetal,
                      disabledForegroundColor: AppColors.silverGray,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.silverGray,
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(
                      isSubmitting ? 'Menyimpan' : 'Simpan',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.gymGold, size: 20),
      labelStyle: const TextStyle(
        color: AppColors.silverGray,
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: AppColors.steelBlack,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gunmetal),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gymGold, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    );
  }
}

class _EditProfileLayoutSpec {
  const _EditProfileLayoutSpec({
    required this.maxContentWidth,
    required this.pagePadding,
    required this.sectionGap,
  });

  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final double sectionGap;

  factory _EditProfileLayoutSpec.fromWidth(double width) {
    if (width >= 600) {
      return const _EditProfileLayoutSpec(
        maxContentWidth: 560,
        pagePadding: EdgeInsets.fromLTRB(32, 32, 32, 32),
        sectionGap: 20,
      );
    }

    return const _EditProfileLayoutSpec(
      maxContentWidth: 480,
      pagePadding: EdgeInsets.fromLTRB(20, 24, 20, 24),
      sectionGap: 18,
    );
  }
}

String _profileInitials(String name) {
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

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
