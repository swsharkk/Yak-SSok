import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'signup_screen.dart';
import 'widgets/login_button.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  static const _logoPath = 'assets/yakssok_logo_final.png';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (Firebase.apps.isEmpty) {
      setState(() {
        _errorMessage = 'Firebase 설정 파일을 추가한 뒤 다시 실행해주세요.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _authErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '로그인 실패: $e';
      });
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    final detail = e.message ?? e.code;
    return switch (e.code) {
      'invalid-email' => '이메일 형식을 확인해주세요.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        AppStrings.loginFailedMessage,
      'operation-not-allowed' =>
        'Firebase Console에서 Email/Password 로그인을 활성화해주세요. (${e.code})',
      'configuration-not-found' ||
      'internal-error' =>
        'Firebase Authentication 설정을 확인해주세요. (${e.code}: $detail)',
      _ => '로그인 실패: ${e.code} - $detail',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXxl,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                _logoPath,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppDimensions.paddingSm),
              Text(
                AppStrings.loginSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(flex: 2),
              _InputField(
                controller: _emailController,
                hint: AppStrings.emailHint,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _InputField(
                controller: _passwordController,
                hint: AppStrings.passwordHint,
                obscureText: true,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppDimensions.paddingSm),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.alertPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.paddingXl),
              LoginButton(
                label: AppStrings.login,
                backgroundColor: AppColors.progressTeal,
                foregroundColor: Colors.white,
                onTap: _isLoading ? () {} : _login,
              ),
              const Spacer(flex: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      AppStrings.findAccount,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Text('|', style: TextStyle(color: AppColors.textMuted)),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: const Text(
                      AppStrings.signUp,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
          vertical: AppDimensions.paddingLg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
