import 'package:flutter/material.dart';

import 'package:do_gym/core/colors.dart';

class FormLogin extends StatelessWidget {
  const FormLogin({
    super.key,
    required this.identityController,
    required this.passwordController,
    required this.identityFocusNode,
    required this.passwordFocusNode,
    required this.identityActive,
    required this.passwordActive,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  final TextEditingController identityController;
  final TextEditingController passwordController;
  final FocusNode identityFocusNode;
  final FocusNode passwordFocusNode;
  final bool identityActive;
  final bool passwordActive;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.graphiteBlack.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.gunmetal),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0AFFFFFF),
              blurRadius: 1,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          children: [
            _LoginField(
              label: 'Email',
              controller: identityController,
              focusNode: identityFocusNode,
              active: identityActive,
              icon: Icons.mail_outline_rounded,
              hintText: 'contoh: member@email.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              enabled: !isSubmitting,
              onSubmitted: (_) => passwordFocusNode.requestFocus(),
            ),
            const SizedBox(height: 20),
            _LoginField(
              label: 'Password',
              controller: passwordController,
              focusNode: passwordFocusNode,
              active: passwordActive,
              icon: Icons.lock_outline_rounded,
              hintText: 'Masukkan password',
              obscureText: obscurePassword,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !isSubmitting,
              onSubmitted: (_) {
                if (!isSubmitting) {
                  onSubmit();
                }
              },
              suffix: IconButton(
                onPressed: isSubmitting ? null : onTogglePassword,
                tooltip: obscurePassword
                    ? 'Tampilkan password'
                    : 'Sembunyikan password',
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.ironGray,
                  size: 20,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: errorMessage == null
                  ? const SizedBox.shrink()
                  : Padding(
                      key: const ValueKey<String>('loginError'),
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A1717),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF7D2A2A)),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFFFB4AB),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isSubmitting
                        ? null
                        : () => onRememberChanged(!rememberMe),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: isSubmitting ? null : onRememberChanged,
                            activeColor: AppColors.gymGold,
                            checkColor: AppColors.blackCore,
                            side: const BorderSide(color: AppColors.gunmetal),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Ingat saya',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.silverGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gymGold,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Lupa password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                key: const ValueKey<String>('submitButton'),
                onPressed: isSubmitting ? null : onSubmit,
                iconAlignment: IconAlignment.end,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ironGray,
                        ),
                      )
                    : const Icon(Icons.chevron_right_rounded, size: 22),
                label: Text(isSubmitting ? 'Memproses...' : 'Masuk Sekarang'),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.steelBlack,
                  disabledForegroundColor: AppColors.ironGray,
                  backgroundColor: AppColors.gymGold,
                  foregroundColor: AppColors.blackCore,
                  elevation: 0,
                  shadowColor: AppColors.gymGold.withValues(alpha: 0.20),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.active,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool active;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.silverGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 56),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.graphiteBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? AppColors.gymGold.withValues(alpha: 0.58)
                  : AppColors.gunmetal,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.gymGold.withValues(alpha: 0.08),
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: active ? AppColors.gymGold : AppColors.ironGray,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: ValueKey<String>('${label.toLowerCase()}Input'),
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  obscureText: obscureText,
                  enableSuggestions: enableSuggestions,
                  autocorrect: autocorrect,
                  autofillHints: autofillHints,
                  onSubmitted: onSubmitted,
                  cursorColor: AppColors.gymGold,
                  style: const TextStyle(
                    color: AppColors.metallicWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.ironGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    isCollapsed: true,
                  ),
                ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        ),
      ],
    );
  }
}
