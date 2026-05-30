import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../home/screen/home_screen.dart';
import 'widget/footer_login.dart';
import 'widget/form_login.dart';
import 'widget/header_login.dart';
import 'widget/hero_copy.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _identityFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  bool get _hasIdentity => _identityController.text.trim().isNotEmpty;
  bool get _hasPassword => _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _identityController.addListener(_refreshState);
    _passwordController.addListener(_refreshState);
    _identityFocusNode.addListener(_refreshState);
    _passwordFocusNode.addListener(_refreshState);
  }

  @override
  void dispose() {
    _identityController
      ..removeListener(_refreshState)
      ..dispose();
    _passwordController
      ..removeListener(_refreshState)
      ..dispose();
    _identityFocusNode
      ..removeListener(_refreshState)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_refreshState)
      ..dispose();
    super.dispose();
  }

  void _refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _submit() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final LoginLayoutSpec spec = LoginLayoutSpec.fromWidth(
              constraints.maxWidth,
            );
            final double minHeight =
                (constraints.maxHeight - spec.pagePadding.vertical)
                    .clamp(0, double.infinity)
                    .toDouble();

            return Stack(
              children: [
                Positioned(
                  top: spec.isExpanded ? -180 : -112,
                  right: spec.isExpanded ? -120 : -96,
                  child: _GlowOrb(
                    size: spec.isExpanded ? 420 : 320,
                    color: AppColors.gymGold,
                    opacity: spec.isExpanded ? 0.18 : 0.20,
                  ),
                ),
                Positioned(
                  top: spec.isExpanded ? 260 : 208,
                  left: spec.isExpanded ? -160 : -112,
                  child: _GlowOrb(
                    size: spec.isExpanded ? 360 : 288,
                    color: AppColors.darkGold,
                    opacity: spec.isExpanded ? 0.10 : 0.12,
                  ),
                ),
                SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: spec.pagePadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: spec.maxContentWidth,
                        ),
                        child: _LoginSurface(
                          spec: spec,
                          child: spec.isExpanded
                              ? _ExpandedLoginContent(
                                  spec: spec,
                                  identityController: _identityController,
                                  passwordController: _passwordController,
                                  identityFocusNode: _identityFocusNode,
                                  passwordFocusNode: _passwordFocusNode,
                                  identityActive:
                                      _hasIdentity ||
                                      _identityFocusNode.hasFocus,
                                  passwordActive:
                                      _hasPassword ||
                                      _passwordFocusNode.hasFocus,
                                  obscurePassword: _obscurePassword,
                                  rememberMe: _rememberMe,
                                  onTogglePassword: _togglePasswordVisibility,
                                  onRememberChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  onSubmit: _submit,
                                )
                              : _StackedLoginContent(
                                  spec: spec,
                                  identityController: _identityController,
                                  passwordController: _passwordController,
                                  identityFocusNode: _identityFocusNode,
                                  passwordFocusNode: _passwordFocusNode,
                                  identityActive:
                                      _hasIdentity ||
                                      _identityFocusNode.hasFocus,
                                  passwordActive:
                                      _hasPassword ||
                                      _passwordFocusNode.hasFocus,
                                  obscurePassword: _obscurePassword,
                                  rememberMe: _rememberMe,
                                  onTogglePassword: _togglePasswordVisibility,
                                  onRememberChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  onSubmit: _submit,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LoginLayoutSpec {
  const LoginLayoutSpec({
    required this.isExpanded,
    required this.isMedium,
    required this.maxContentWidth,
    required this.formMaxWidth,
    required this.pagePadding,
    required this.surfacePadding,
    required this.surfaceRadius,
    required this.headerToHeroGap,
    required this.heroToFormGap,
    required this.formToFooterGap,
  });

  final bool isExpanded;
  final bool isMedium;
  final double maxContentWidth;
  final double formMaxWidth;
  final EdgeInsets pagePadding;
  final EdgeInsets surfacePadding;
  final double surfaceRadius;
  final double headerToHeroGap;
  final double heroToFormGap;
  final double formToFooterGap;

  bool get hasSurfaceFrame => isExpanded || isMedium;

  factory LoginLayoutSpec.fromWidth(double width) {
    if (width >= 840) {
      return const LoginLayoutSpec(
        isExpanded: true,
        isMedium: false,
        maxContentWidth: 1040,
        formMaxWidth: 430,
        pagePadding: EdgeInsets.symmetric(horizontal: 56, vertical: 48),
        surfacePadding: EdgeInsets.all(48),
        surfaceRadius: 40,
        headerToHeroGap: 64,
        heroToFormGap: 0,
        formToFooterGap: 28,
      );
    }

    if (width >= 600) {
      return const LoginLayoutSpec(
        isExpanded: false,
        isMedium: true,
        maxContentWidth: 560,
        formMaxWidth: 480,
        pagePadding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        surfacePadding: EdgeInsets.all(32),
        surfaceRadius: 36,
        headerToHeroGap: 44,
        heroToFormGap: 32,
        formToFooterGap: 28,
      );
    }

    return const LoginLayoutSpec(
      isExpanded: false,
      isMedium: false,
      maxContentWidth: 480,
      formMaxWidth: double.infinity,
      pagePadding: EdgeInsets.fromLTRB(24, 32, 24, 28),
      surfacePadding: EdgeInsets.zero,
      surfaceRadius: 0,
      headerToHeroGap: 40,
      heroToFormGap: 32,
      formToFooterGap: 28,
    );
  }
}

class _LoginSurface extends StatelessWidget {
  const _LoginSurface({required this.spec, required this.child});

  final LoginLayoutSpec spec;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!spec.hasSurfaceFrame) {
      return child;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.blackCore.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(spec.surfaceRadius),
        border: Border.all(color: AppColors.gunmetal),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.56),
            blurRadius: 80,
            offset: const Offset(0, 28),
          ),
          BoxShadow(
            color: AppColors.gymGold.withValues(alpha: 0.06),
            blurRadius: 72,
          ),
        ],
      ),
      child: Padding(padding: spec.surfacePadding, child: child),
    );
  }
}

class _ExpandedLoginContent extends StatelessWidget {
  const _ExpandedLoginContent({
    required this.spec,
    required this.identityController,
    required this.passwordController,
    required this.identityFocusNode,
    required this.passwordFocusNode,
    required this.identityActive,
    required this.passwordActive,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  final LoginLayoutSpec spec;
  final TextEditingController identityController;
  final TextEditingController passwordController;
  final FocusNode identityFocusNode;
  final FocusNode passwordFocusNode;
  final bool identityActive;
  final bool passwordActive;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderLogin(),
                SizedBox(height: spec.headerToHeroGap),
                const HeroCopy(titleFontSize: 40, maxDescriptionWidth: 420),
              ],
            ),
          ),
        ),
        const SizedBox(width: 56),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: spec.formMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormLogin(
                identityController: identityController,
                passwordController: passwordController,
                identityFocusNode: identityFocusNode,
                passwordFocusNode: passwordFocusNode,
                identityActive: identityActive,
                passwordActive: passwordActive,
                obscurePassword: obscurePassword,
                rememberMe: rememberMe,
                onTogglePassword: onTogglePassword,
                onRememberChanged: onRememberChanged,
                onSubmit: onSubmit,
              ),
              SizedBox(height: spec.formToFooterGap),
              const FooterLogin(),
            ],
          ),
        ),
      ],
    );
  }
}

class _StackedLoginContent extends StatelessWidget {
  const _StackedLoginContent({
    required this.spec,
    required this.identityController,
    required this.passwordController,
    required this.identityFocusNode,
    required this.passwordFocusNode,
    required this.identityActive,
    required this.passwordActive,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  final LoginLayoutSpec spec;
  final TextEditingController identityController;
  final TextEditingController passwordController;
  final FocusNode identityFocusNode;
  final FocusNode passwordFocusNode;
  final bool identityActive;
  final bool passwordActive;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: spec.isMedium ? Alignment.center : Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spec.formMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderLogin(),
            SizedBox(height: spec.headerToHeroGap),
            HeroCopy(
              titleFontSize: spec.isMedium ? 36 : 32,
              maxDescriptionWidth: spec.isMedium ? 420 : 320,
            ),
            SizedBox(height: spec.heroToFormGap),
            FormLogin(
              identityController: identityController,
              passwordController: passwordController,
              identityFocusNode: identityFocusNode,
              passwordFocusNode: passwordFocusNode,
              identityActive: identityActive,
              passwordActive: passwordActive,
              obscurePassword: obscurePassword,
              rememberMe: rememberMe,
              onTogglePassword: onTogglePassword,
              onRememberChanged: onRememberChanged,
              onSubmit: onSubmit,
            ),
            SizedBox(height: spec.formToFooterGap),
            const FooterLogin(),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity),
              blurRadius: 64,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }
}
