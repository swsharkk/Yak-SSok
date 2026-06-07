import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/guardian_service.dart';
import 'guardian_dashboard_screen.dart';
import 'guardian_settings_screen.dart';

class GuardianMainScreen extends StatefulWidget {
  const GuardianMainScreen({super.key});

  @override
  State<GuardianMainScreen> createState() => _GuardianMainScreenState();
}

class _GuardianMainScreenState extends State<GuardianMainScreen> {
  GuardianElderStatus? _status;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await GuardianService.getElderStatus();
      if (mounted) setState(() { _status = status; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _GuardianAppBar(
              onRefresh: _loadData,
              elderName: _status?.elder.name,
              todayTotal: _status?.total ?? 0,
              todayDone: _status?.done ?? 0,
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.progressTeal),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(child: _ErrorState(message: _error!, onRetry: _loadData))
            else if (_status == null)
              const SliverFillRemaining(child: _NoElderState())
            else ...[
              SliverToBoxAdapter(child: _MonitoringBanner(name: _status!.elder.name)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingXxl,
                  AppDimensions.paddingLg,
                  AppDimensions.paddingXxl,
                  AppDimensions.paddingXxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _AdherenceCard(total: _status!.total, done: _status!.done),
                    const SizedBox(height: AppDimensions.paddingLg),
                    _RealtimeStatusCard(schedules: _status!.schedules),
                    const SizedBox(height: AppDimensions.paddingLg),
                    _TodayMedicineList(
                      schedules: _status!.schedules,
                      elderName: _status!.elder.name,
                    ),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 앱바 ────────────────────────────────────────────────────────────────────

class _GuardianAppBar extends StatelessWidget {
  const _GuardianAppBar({
    required this.onRefresh,
    this.elderName,
    this.todayTotal = 0,
    this.todayDone = 0,
  });
  final VoidCallback onRefresh;
  final String? elderName;
  final int todayTotal;
  final int todayDone;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      scrolledUnderElevation: 0,
      floating: true,
      toolbarHeight: 60,
      title: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'YAK-',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'SSOK',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.progressTeal,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.progressTealLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            child: const Text(
              '보호자 서비스',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.progressTeal,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded, color: AppColors.textPrimary),
          tooltip: '주간 리포트',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GuardianDashboardScreen(
                elderName: elderName,
                todayTotal: todayTotal,
                todayDone: todayDone,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
          onPressed: onRefresh,
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GuardianSettingsScreen()),
          ),
        ),
      ],
    );
  }
}

// ── 모니터링 배너 ────────────────────────────────────────────────────────────

class _MonitoringBanner extends StatelessWidget {
  const _MonitoringBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.progressTealLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXxl,
        vertical: AppDimensions.paddingMd,
      ),
      child: Row(
        children: [
          const Icon(Icons.home_rounded, size: 16, color: AppColors.progressTeal),
          const SizedBox(width: 6),
          Text(
            '$name 님의 복약 상태를 모니터링 중입니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.progressTealDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── 공통 카드 래퍼 ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          child,
        ],
      ),
    );
  }
}

// ── 오늘의 복약 달성률 ────────────────────────────────────────────────────────

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.total, required this.done});
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final rate = total > 0 ? done / total : 0.0;
    final remaining = total - done;

    return _SectionCard(
      title: '오늘의 복약 달성률',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total > 0 ? '${(rate * 100).round()}%' : '-',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.progressTeal,
                  height: 1,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                      child: LinearProgressIndicator(
                        value: rate,
                        minHeight: 10,
                        backgroundColor: AppColors.divider,
                        color: AppColors.progressTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      total == 0
                          ? '오늘 예정된 복약이 없습니다'
                          : '총 $total회 중 $done회 완료'
                              '${remaining > 0 ? ' / $remaining회 남음' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 실시간 복약 현황 ──────────────────────────────────────────────────────────

class _RealtimeStatusCard extends StatelessWidget {
  const _RealtimeStatusCard({required this.schedules});
  final List<GuardianScheduleItem> schedules;

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const _SectionCard(
        title: '실시간 복약 현황 조회',
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '오늘 예정된 복약이 없습니다.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    // slot 기준으로 그룹화하되 최대 4개
    final slots = ['morning', 'lunch', 'evening', 'bedtime'];
    final slotItems = slots
        .map((s) => schedules.where((item) => item.slot == s).toList())
        .where((list) => list.isNotEmpty)
        .toList();

    if (slotItems.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: '실시간 복약 현황 조회',
      child: Row(
        children: [
          for (int i = 0; i < slotItems.length; i++) ...[
            Expanded(child: _SlotStatusItem(items: slotItems[i])),
            if (i < slotItems.length - 1)
              _ArrowConnector(done: slotItems[i].every((e) => e.isDone)),
          ],
        ],
      ),
    );
  }
}

class _SlotStatusItem extends StatelessWidget {
  const _SlotStatusItem({required this.items});
  final List<GuardianScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    final first = items.first;
    final allDone = items.every((e) => e.isDone);
    final anyMissed = items.any((e) => e.isMissed);

    final circleColor = allDone
        ? AppColors.progressTeal
        : anyMissed
            ? AppColors.alertPrimary
            : AppColors.divider;

    final icon = allDone
        ? Icons.check_rounded
        : anyMissed
            ? Icons.close_rounded
            : Icons.schedule_rounded;

    final statusLabel = allDone
        ? '복용완료'
        : anyMissed
            ? '미복용'
            : '대기';

    final subLabel = allDone
        ? _formatTime(first.takenAt)
        : anyMissed
            ? '복약 시간 지남'
            : first.slotTime;

    return Column(
      children: [
        Text(
          '${first.slotLabel}[${first.slotTime}]',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: circleColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2),
          ),
          child: Icon(icon, color: circleColor, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          statusLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: circleColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subLabel,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} 완료';
    } catch (_) {
      return '완료';
    }
  }
}

class _ArrowConnector extends StatelessWidget {
  const _ArrowConnector({required this.done});
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 18,
        color: done ? AppColors.progressTeal : AppColors.divider,
      ),
    );
  }
}

// ── 오늘의 복약 리스트 ────────────────────────────────────────────────────────

class _TodayMedicineList extends StatelessWidget {
  const _TodayMedicineList({
    required this.schedules,
    required this.elderName,
  });
  final List<GuardianScheduleItem> schedules;
  final String elderName;

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const _SectionCard(
        title: '오늘의 복약 리스트',
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '오늘 예정된 복약이 없습니다.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return _SectionCard(
      title: '오늘의 복약 리스트',
      child: Column(
        children: [
          for (int i = 0; i < schedules.length; i++) ...[
            if (i > 0) const Divider(height: 24, color: AppColors.divider),
            _MedicineListItem(item: schedules[i], elderName: elderName),
          ],
        ],
      ),
    );
  }
}

class _MedicineListItem extends StatefulWidget {
  const _MedicineListItem({required this.item, required this.elderName});
  final GuardianScheduleItem item;
  final String elderName;

  @override
  State<_MedicineListItem> createState() => _MedicineListItemState();
}

class _MedicineListItemState extends State<_MedicineListItem> {
  bool _sent = false;

  void _sendReminder() {
    setState(() => _sent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.elderName} 님께 복약 알림을 보냈습니다.'),
        backgroundColor: AppColors.progressTeal,
      ),
    );
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _sent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDone = item.isDone;
    final isMissed = item.isMissed;

    String statusLabel;
    Color statusColor;
    Color statusBg;
    if (isDone) {
      statusLabel = '복용완료';
      statusColor = AppColors.progressTeal;
      statusBg = AppColors.progressTealLight;
    } else if (isMissed) {
      statusLabel = '미복용';
      statusColor = AppColors.alertPrimary;
      statusBg = AppColors.alertBg;
    } else {
      statusLabel = '대기중';
      statusColor = AppColors.textSecondary;
      statusBg = AppColors.background;
    }

    String takenInfo;
    if (isDone && item.takenAt != null) {
      try {
        final dt = DateTime.parse(item.takenAt!).toLocal();
        takenInfo =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} 정상 복용 완료';
      } catch (_) {
        takenInfo = '복용 완료';
      }
    } else if (isMissed) {
      takenInfo = '복약 시간 지남';
    } else {
      takenInfo = '${item.slotLabel} ${item.slotTime} 예정';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: Border.all(color: statusColor, width: 1.2),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.slotLabel} [${item.slotTime}]',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.medicineName} (${item.doseCount}알)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                takenInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: isMissed ? AppColors.alertPrimary : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isDone)
          const Icon(Icons.check_circle_rounded,
              color: AppColors.progressTeal, size: 24)
        else if (isMissed)
          TextButton(
            onPressed: _sent ? null : _sendReminder,
            style: TextButton.styleFrom(
              backgroundColor: _sent
                  ? AppColors.divider
                  : AppColors.alertPrimary,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _sent ? '전송됨' : '복약 알림',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

// ── 빈 상태 ──────────────────────────────────────────────────────────────────

class _NoElderState extends StatelessWidget {
  const _NoElderState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.progressTealLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link_off_rounded,
                  size: 36, color: AppColors.progressTeal),
            ),
            const SizedBox(height: AppDimensions.paddingXl),
            const Text(
              '연동된 어르신이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMd),
            const Text(
              '어르신 앱의 인증 코드로\n회원가입 후 연동해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.alertPrimary),
            const SizedBox(height: AppDimensions.paddingLg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.paddingXl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.progressTeal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
