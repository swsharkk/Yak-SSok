import 'package:flutter/material.dart';

import '../../../core/responsive.dart';
import '../../../core/theme.dart';
import '../../../widgets/emergency_button.dart';

/// 홈 화면 상단 — 로고 + 긴급 호출 버튼.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onEmergencyPressed});

  static const _logoPath = 'assets/yakssok_logo_final.png';

  final VoidCallback? onEmergencyPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(vertical: AppDimensions.paddingXs),
          child: Transform.translate(
            offset: Offset(AppResponsive.headerLogoOffset(context), 0),
            child: Image.asset(
              _logoPath,
              width: AppResponsive.logoWidth(context),
              height: AppResponsive.logoHeight(context),
              fit: BoxFit.cover,
              semanticLabel: AppStrings.appName,
            ),
          ),
        ),
        const Spacer(),
        EmergencyButton(onPressed: onEmergencyPressed),
        const SizedBox(width: AppDimensions.paddingMd),
      ],
    );
  }
}
