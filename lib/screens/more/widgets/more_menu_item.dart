import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class MoreMenuItem extends StatelessWidget {
  const MoreMenuItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {},
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
                      color: iconBackgroundColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Icon(icon, color: iconColor, size: AppDimensions.iconLg),
                  ),
                  const SizedBox(width: AppDimensions.paddingLg),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: AppDimensions.paddingXl + 44 + AppDimensions.paddingLg,
            endIndent: AppDimensions.paddingXl,
            color: AppColors.divider,
          ),
      ],
    );
  }
}
