import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../widgets/emergency_button.dart';
import 'widgets/calendar_schedule_section.dart';
import 'widgets/calendar_stats_section.dart';
import 'widgets/medicine_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            snap: false,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: _CalendarAppBar(),
            titleSpacing: 0,
            toolbarHeight: 64,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.paddingLg,
              AppDimensions.paddingMd,
              AppDimensions.paddingLg,
              AppDimensions.padding3xl,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CalendarTitle(),
                  SizedBox(height: AppDimensions.paddingXl),
                  MedicineCalendar(),
                  SizedBox(height: AppDimensions.paddingXxl),
                  CalendarScheduleSection(),
                  SizedBox(height: AppDimensions.paddingXxl),
                  CalendarStatsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarAppBar extends StatelessWidget {
  const _CalendarAppBar();

  static const _logoPath = 'assets/yakssok_logo_final.png';

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
        const EmergencyButton(),
        const SizedBox(width: AppDimensions.paddingMd),
      ],
    );
  }
}

class _CalendarTitle extends StatelessWidget {
  const _CalendarTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.calendarTitle,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: AppDimensions.paddingXs),
        Text(
          AppStrings.calendarSubtitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.progressTeal,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
