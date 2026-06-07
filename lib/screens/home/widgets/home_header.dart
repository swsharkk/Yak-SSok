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
        ExcludeSemantics(
          child: SizedBox(
            width: AppResponsive.logoWidth(context),
            height: AppResponsive.logoHeight(context),
            child: ClipRect(
              child: Image.asset(
                _logoPath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
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
