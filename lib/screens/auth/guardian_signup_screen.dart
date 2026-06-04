import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'widgets/login_button.dart'; // 💡 상대 경로를 auth/widgets/login_button.dart 구조로 완벽 교정

import 'package:flutter/services.dart';

class GuardianSignupScreen extends StatefulWidget {
  const GuardianSignupScreen({super.key});

  @override
  State<GuardianSignupScreen> createState() => _GuardianSignupScreenState();
}

class _GuardianSignupScreenState extends State<GuardianSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _seniorNameController = TextEditingController();
  final _seniorCodeController = TextEditingController();

  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _seniorNameController.dispose();
    _seniorCodeController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (Firebase.apps.isEmpty) {
      setState(() => _errorMessage = 'Firebase 설정 파일을 추가한 뒤 다시 실행해주세요.');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;
    final seniorName = _seniorNameController.text.trim();
    final seniorCode = _seniorCodeController.text.trim();

    if (email.isEmpty || password.isEmpty || seniorName.isEmpty || seniorCode.isEmpty) {
      setState(() => _errorMessage = '필수 항목을 모두 입력해주세요.');
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
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('회원가입 완료'),
          content: const Text('보호자 회원가입이 완료되었습니다!\n로그인 후 서비스를 이용해 주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); 
                Navigator.pop(context); 
              },
              child: const Text(
                '확인', 
                style: TextStyle(
                  color: Color(0xFF1A5A96), 
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      );
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
    const guardianThemeColor = Color(0xFF1A5A96);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '보호자 회원가입',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                controller: _passwordController,
                label: '비밀번호',
                hint: '영문, 숫자 6자리 이상',
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
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
                    _passwordConfirmVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _passwordConfirmVisible = !_passwordConfirmVisible),
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingXxl),
              
              _SignupField(
                controller: _seniorNameController,
                label: '연동 대상자 이름',
                hint: '예) 홍길동',
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              _SignupField(
                controller: _seniorCodeController,
                label: '인증 코드',
                hint: '시니어 앱에서 발급된 6자리 코드 입력',
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
              
              // 💡 버튼 텍스트 '가입하기' 변경 및 언제나 동일한 파란색(guardianThemeColor) 적용
              LoginButton(
                label: '가입하기',
                backgroundColor: guardianThemeColor,
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

// 📝 [추가 위치]: guardian_signup_screen.dart 파일 맨 밑에 새로 붙여넣기
 // 💡 복사 기능을 위해 상단 import 구역에 추가하거나 여기에 같이 적어주세요.

class _VerificationCodeCard extends StatelessWidget {
  const _VerificationCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
          vertical: AppDimensions.paddingLg,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.progressTealLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                color: AppColors.progressTeal,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '보호자 연동 인증 코드',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 15,
                      letterSpacing: 2,
                      color: AppColors.progressTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 💡 클립보드에 인증코드 즉시 복사
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('인증 코드가 클립보드에 복사되었습니다.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
              child: const Text(
                '복사',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}