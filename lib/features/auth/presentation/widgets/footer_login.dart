import 'package:flutter/material.dart';

import 'package:do_gym/core/colors.dart';

// Static footer copy for secondary login actions and policy acknowledgement.
class FooterLogin extends StatelessWidget {
  const FooterLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Belum punya akun? ',
                style: TextStyle(
                  color: AppColors.silverGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gymGold,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Daftar Member',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 320),
            child: Text(
              'Dengan masuk, kamu menyetujui Terms & Conditions serta Privacy Policy DO GYM.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ironGray,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
