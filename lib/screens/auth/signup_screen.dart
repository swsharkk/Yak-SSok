import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/backend_auth_service.dart';
import '../main_screen.dart';
import 'widgets/login_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    if (email.isEmpty || nickname.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '모든 항목을 입력해주세요.');
      return;
    }

    if (password != passwordConfirm) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await BackendAuthService.signUpAndLogin(
        email: email,
        password: password,
        nickname: nickname,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _backendErrorMessage(e);
      });
    }
  }

  String _backendErrorMessage(Object e) {
    final message = e.toString().replaceFirst('Exception: ', '');
    if (message.contains('already') || message.contains('이미')) {
      return '이미 가입된 이메일입니다.';
    }
    if (message.contains('password') || message.contains('비밀번호')) {
      return '비밀번호는 6자리 이상이어야 합니다.';
    }
    return '백엔드 회원가입 실패: $message';
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
        title: const Text(AppStrings.signUp),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingXxl),
              _SignupField(
                controller: _emailController,
                label: '이메일 입력',
                hint: 'example@naver.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _SignupField(
                controller: _nicknameController,
                label: '닉네임 입력',
                hint: '닉네임을 입력해주세요',
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _SignupField(
                controller: _passwordController,
                label: '비밀번호',
                hint: '영문, 숫자 6자리 이상',
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _SignupField(
                controller: _passwordConfirmController,
                label: '비밀번호 확인',
                hint: '비밀번호 확인',
                obscureText: !_passwordConfirmVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordConfirmVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(
                      () => _passwordConfirmVisible = !_passwordConfirmVisible),
                ),
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
              const SizedBox(height: AppDimensions.paddingXxl),
              LoginButton(
                label: '가입하기',
                backgroundColor: AppColors.progressTeal,
                foregroundColor: Colors.white,
                onTap: _isLoading ? () {} : _signup,
              ),
              const SizedBox(height: AppDimensions.paddingXxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXl,
              vertical: AppDimensions.paddingLg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
