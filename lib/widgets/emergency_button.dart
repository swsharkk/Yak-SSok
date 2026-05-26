import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../providers/guardian_provider.dart';

class EmergencyButton extends ConsumerWidget {
  const EmergencyButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: AppDimensions.emergencyButtonHeight,
      child: ElevatedButton(
        onPressed: onPressed ?? () => _onTap(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text(AppStrings.emergencyCall),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    final guardianNumber =
        ref.read(guardianControllerProvider).valueOrNull;

    if (guardianNumber != null && guardianNumber.isNotEmpty) {
      await _call(guardianNumber, context);
    } else {
      _showSetupPrompt(context);
    }
  }

  Future<void> _call(String number, BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: number);
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('전화 앱을 열 수 없어요')),
      );
    }
  }

  void _showSetupPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          '보호자 번호 미설정',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          '내 정보에서 보호자 전화번호를 먼저 등록해 주세요.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
