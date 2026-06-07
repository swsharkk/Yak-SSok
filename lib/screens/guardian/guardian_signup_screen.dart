import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/backend_auth_service.dart';
import 'guardian_main_screen.dart';

class GuardianSignupScreen extends StatefulWidget {
  const GuardianSignupScreen({super.key});

  @override
  State<GuardianSignupScreen> createState() => _GuardianSignupScreenState();
}

class _GuardianSignupScreenState extends State<GuardianSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _linkCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    _linkCodeController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _passwordConfirmController.text;
    final nickname = _nicknameController.text.trim();
    final linkCode = _linkCodeController.text.trim();

    if (email.isEmpty || password.isEmpty || nickname.isEmpty || linkCode.isEmpty) {
      setState(() => _errorMessage = '모든 항목을 입력해주세요.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = '비밀번호가 일치하지 않습니다.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = '비밀번호는 6자리 이상이어야 합니다.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    try {
      await BackendAuthService.signUpAndLogin(
        email: email,
        password: password,
        nickname: nickname,
        role: 'guardian',
        linkCode: linkCode,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GuardianMainScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = _toErrorMessage(e);
      });
    }
  }

  String _toErrorMessage(Object e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg.contains('already') || msg.contains('이미')) return '이미 가입된 이메일입니다.';
    if (msg.contains('password') || msg.contains('비밀번호')) return '비밀번호는 6자리 이상이어야 합니다.';
    return '회원가입 실패: $msg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '보호자 회원가입',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingXxl),
              _Field(
                controller: _emailController,
                label: '이메일 입력',
                hint: 'example@naver.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _Field(
                controller: _passwordController,
                label: '비밀번호',
                hint: '영문, 숫자 6자리 이상',
                obscure: _obscurePassword,
                suffix: _VisibilityToggle(
                  visible: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _Field(
                controller: _passwordConfirmController,
                label: '비밀번호 확인',
                hint: '비밀번호 확인',
                obscure: _obscureConfirm,
                suffix: _VisibilityToggle(
                  visible: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _Field(
                controller: _nicknameController,
                label: '연동 대상자 이름',
                hint: '예) 홍길동',
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _Field(
                controller: _linkCodeController,
                label: '인증 코드',
                hint: '시니어 앱에서 발급된 6자리 코드 입력',
                keyboardType: TextInputType.text,
                maxLength: 6,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppDimensions.paddingMd),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.alertPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.paddingXxl),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.progressTeal,
                    disabledBackgroundColor:
                        AppColors.progressTeal.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXl),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          '가입하기',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final int? maxLength;

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
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            suffixIcon: suffix,
            counterText: '',
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

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.visible, required this.onToggle});

  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}
