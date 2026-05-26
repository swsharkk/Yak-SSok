import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'email_login_screen.dart';
import 'widgets/login_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _logoPath = 'assets/yakssok_logo_final.png';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXxl),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const _LogoSection(logoPath: _logoPath),
                const Spacer(flex: 3),
                _LoginButtons(context: context),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.logoPath});

  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          logoPath,
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppDimensions.paddingMd),
        Text(
          AppStrings.loginSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
        ),
      ],
    );
  }
}

class _LoginButtons extends StatelessWidget {
  const _LoginButtons({required this.context});

  final BuildContext context;

  void _showComingSoon(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text(AppStrings.socialLoginComingSoon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginButton(
          label: AppStrings.loginWithEmail,
          backgroundColor: AppColors.progressTeal,
          foregroundColor: Colors.white,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMd),
        _ImageLoginButton(
          assetPath: 'assets/kakao_login_btn.png',
          onTap: () => _showComingSoon(context),
        ),
        const SizedBox(height: AppDimensions.paddingMd),
        _ImageLoginButton(
          assetPath: 'assets/naver_login_btn.png',
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }
}

class _ImageLoginButton extends StatelessWidget {
  const _ImageLoginButton({required this.assetPath, required this.onTap});

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        width: double.infinity,
        height: 54,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
