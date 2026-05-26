import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
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
    if (Firebase.apps.isEmpty) {
      setState(() => _errorMessage = 'Firebase 설정 파일을 추가한 뒤 다시 실행해주세요.');
      return;
    }

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
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      await user?.updateDisplayName(nickname);

      if (!mounted) return;
      Navigator.pop(context);
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
        _errorMessage = e.toString();
      });
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    final detail = e.message ?? e.code;
    final msg = detail.toLowerCase();
    return switch (e.code) {
      'email-already-in-use' => '이미 가입된 이메일입니다.',
      'invalid-email' => '이메일 형식을 확인해주세요.',
      'weak-password' => '비밀번호는 6자리 이상이어야 합니다.',
      'operation-not-allowed' =>
        'Firebase Console에서 Email/Password 로그인을 활성화해주세요. (${e.code})',
      'configuration-not-found' ||
      'internal-error' =>
        'Firebase Authentication 설정을 확인해주세요. (${e.code}: $detail)',
      _ when msg.contains('password') && msg.contains('6') =>
        '비밀번호는 6자리 이상이어야 합니다.',
      _ => '회원가입 실패: ${e.code} - $detail',
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
