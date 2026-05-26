import 'package:flutter/material.dart';

import '../core/theme.dart';

/// 앱 전역 버튼. 색상/스타일 통일을 위한 래퍼.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.foregroundColor,
    this.outlined = false,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? foregroundColor;
  final bool outlined;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.progressTeal;
    final fg = foregroundColor ?? Colors.white;

    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppDimensions.iconMd),
          const SizedBox(width: AppDimensions.paddingSm),
        ],
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 48,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: bg,
                side: BorderSide(color: bg, width: 1.5),
                shape: shape,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                elevation: 0,
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}
