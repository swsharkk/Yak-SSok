import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';

import '../auth/login_screen.dart';
import '../my_info/my_info_screen.dart';
import '../pharmacy/pharmacy_screen.dart';
import '../saved_medicine/saved_medicine_screen.dart';
import 'dev_mode_screen.dart';
import 'health_info_screen.dart';
import 'settings_screen.dart';
import 'widgets/more_menu_item.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _logoPath = 'assets/yakssok_logo_final.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            snap: true,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Image.asset(
              _logoPath,
              width: 220,
              height: 44,
              fit: BoxFit.cover,
              semanticLabel: AppStrings.appName,
            ),
            toolbarHeight: 64,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingXl,
              AppDimensions.paddingMd,
              AppDimensions.paddingXl,
              AppDimensions.paddingXxl,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.moreTitle,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppDimensions.paddingXl),
                  const _MenuCard(),
                  const SizedBox(height: AppDimensions.paddingXxl),
                  const _DailyQuoteCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Column(
          children: [
            MoreMenuItem(
              icon: Icons.bookmark_rounded,
              iconColor: AppColors.progressTeal,
              iconBackgroundColor: const Color(0xFFE6FAF8),
              label: AppStrings.moreSavedMedicine,
              onTap: () {
                final isLoggedIn = Firebase.apps.isNotEmpty &&
                    FirebaseAuth.instance.currentUser != null;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => isLoggedIn
                        ? const SavedMedicineScreen()
                        : const LoginScreen(),
                  ),
                );
              },
            ),
            MoreMenuItem(
              icon: Icons.local_pharmacy_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBackgroundColor: const Color(0xFFEDE9FE),
              label: '약국 찾기',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PharmacyScreen()),
              ),
            ),
            MoreMenuItem(
              icon: Icons.favorite_rounded,
              iconColor: AppColors.lunchPrimary,
              iconBackgroundColor: AppColors.lunchBg,
              label: AppStrings.moreHealthInfo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealthInfoScreen()),
              ),
            ),
            MoreMenuItem(
              icon: Icons.person_rounded,
              iconColor: AppColors.morningPrimary,
              iconBackgroundColor: AppColors.morningBg,
              label: AppStrings.moreMyInfo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyInfoScreen()),
              ),
            ),
            MoreMenuItem(
              icon: Icons.settings_rounded,
              iconColor: AppColors.textSecondary,
              iconBackgroundColor: AppColors.background,
              label: AppStrings.moreSettings,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            MoreMenuItem(
              icon: Icons.developer_mode_rounded,
              iconColor: AppColors.calendarAmber,
              iconBackgroundColor: const Color(0xFFFEF9C3),
              label: '개발자 모드',
              showDivider: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DevModeScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyQuoteCard extends StatefulWidget {
  const _DailyQuoteCard();

  @override
  State<_DailyQuoteCard> createState() => _DailyQuoteCardState();
}

class _DailyQuoteCardState extends State<_DailyQuoteCard> {
  late final String _quote;

  @override
  void initState() {
    super.initState();
    final index = Random().nextInt(AppStrings.moreDailyQuotes.length);
    _quote = AppStrings.moreDailyQuotes[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: AppColors.progressTeal,
                size: AppDimensions.iconLg,
              ),
              const SizedBox(width: AppDimensions.paddingSm),
              Text(
                AppStrings.moreDailyQuoteTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.progressTeal,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          Text(
            _quote,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
