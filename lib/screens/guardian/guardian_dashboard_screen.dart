import 'package:flutter/material.dart';

import '../../core/theme.dart';

class GuardianDashboardScreen extends StatelessWidget {
  const GuardianDashboardScreen({
    super.key,
    this.elderName,
    this.todayTotal = 0,
    this.todayDone = 0,
  });

  final String? elderName;
  final int todayTotal;
  final int todayDone;

  static const _weeklyRates = [0.88, 0.74, 0.92, 0.83, 0.96, 0.68, 0.91];
  static const _riskTrend = [0.22, 0.28, 0.26, 0.34, 0.41, 0.39, 0.47];

  static List<String> _last7DayLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return '${d.month}/${d.day}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = elderName ?? '어르신';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('보호자 대시보드'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingXl,
          AppDimensions.paddingMd,
          AppDimensions.paddingXl,
          AppDimensions.padding3xl,
        ),
        children: [
          _HeroStatusCard(name: name, total: todayTotal, done: todayDone),
          const SizedBox(height: AppDimensions.paddingLg),
          _MetricGrid(total: todayTotal, done: todayDone),
          const SizedBox(height: AppDimensions.paddingLg),
          _WeeklyAdherenceCard(rates: _weeklyRates, labels: _last7DayLabels()),
          const SizedBox(height: AppDimensions.paddingLg),
          const _RiskPredictionCard(trend: _riskTrend),
          const SizedBox(height: AppDimensions.paddingLg),
          const _RecentAlertsCard(),
        ],
      ),
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({
    required this.name,
    required this.total,
    required this.done,
  });

  final String name;
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final rate = total > 0 ? done / total : 0.0;
    final remaining = total - done;

    final statusLabel = total == 0
        ? '정보 없음'
        : rate == 1.0
            ? '완료'
            : done > 0
                ? '진행중'
                : '미복용';
    final statusColor = total == 0
        ? AppColors.textMuted
        : rate == 1.0
            ? AppColors.progressTeal
            : done > 0
                ? const Color(0xFFF59E0B)
                : AppColors.alertPrimary;

    final subtitle = total == 0
        ? '오늘 예정된 복약 없음'
        : '총 $total회 중 $done회 완료'
            '${remaining > 0 ? " / $remaining회 남음" : ""}';

    final bodyText = total == 0
        ? '오늘 예정된 복약 일정이 없습니다.'
        : done == total
            ? '오늘 예정된 $total회 복약을 모두 완료했어요!'
            : '오늘은 예정된 ${total}회 복약 중 ${done}회를 완료했어요.';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8FFFB), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFBDEFE7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1000A99D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.progressTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.elderly_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name님 복약 현황',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXl),
          Text(
            bodyText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.total, required this.done});

  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final remaining = total - done;
    final todayValue = '$done/$total';
    final todaySub = remaining == 0 && total > 0
        ? '모두 완료!'
        : '$remaining회 남음';

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: '오늘 복약',
            value: todayValue,
            sub: todaySub,
            color: AppColors.progressTeal,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMd),
        const Expanded(
          child: _MetricCard(
            label: '주간 순응도',
            value: '86%',
            sub: '전주 대비 +7%',
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECEEF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            sub,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyAdherenceCard extends StatelessWidget {
  const _WeeklyAdherenceCard({required this.rates, required this.labels});

  final List<double> rates;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: '주간 복약 순응도',
      trailing: '최근 7일',
      child: SizedBox(
        height: 210,
        child: CustomPaint(
          painter: _BarChartPainter(values: rates, labels: labels),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _RiskPredictionCard extends StatelessWidget {
  const _RiskPredictionCard({required this.trend});

  final List<double> trend;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: '복약 순응도 예측',
      trailing: '위험도 리포트',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _StatusPill(label: '주의', color: Color(0xFFF59E0B)),
              SizedBox(width: AppDimensions.paddingSm),
              Text(
                '야간 복약 누락 가능성 증가',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: _LineChartPainter(values: trend),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          const Text(
            '근거: 최근 7일 복용 지연, 복약 횟수, 일정 복잡도, DUR 주의 약물 여부를 종합한 임시 리포트입니다.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentAlertsCard extends StatelessWidget {
  const _RecentAlertsCard();

  @override
  Widget build(BuildContext context) {
    return const _DashboardCard(
      title: '최근 알림',
      trailing: '원격 모니터링',
      child: Column(
        children: [
          _AlertTile(
            icon: Icons.check_circle_rounded,
            color: AppColors.progressTeal,
            title: '아침 약 복용 완료',
            sub: '오늘 오전 9:04',
          ),
          Divider(height: 24, color: AppColors.divider),
          _AlertTile(
            icon: Icons.schedule_rounded,
            color: Color(0xFFF59E0B),
            title: '점심 약 복용 18분 지연',
            sub: '오늘 오후 1:18',
          ),
          Divider(height: 24, color: AppColors.divider),
          _AlertTile(
            icon: Icons.warning_rounded,
            color: AppColors.alertPrimary,
            title: '저녁 약 미복용 위험 감지',
            sub: '예측 알림',
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 23),
        ),
        const SizedBox(width: AppDimensions.paddingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.trailing,
    required this.child,
  });

  final String title;
  final String trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECEEF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                trailing,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXl),
          child,
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({required this.values, this.labels});

  final List<double> values;
  final List<String>? labels;

  static const _labelAreaHeight = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final hasLabels = labels != null && labels!.length == values.length;
    final chartHeight = hasLabels ? size.height - _labelAreaHeight : size.height;

    final gridPaint = Paint()
      ..color = const Color(0xFFECEEF3)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [AppColors.progressTeal, const Color(0xFF6EE7D8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    for (var i = 0; i < 4; i++) {
      final y = chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final gap = size.width / (values.length * 2 + 1);
    final barWidth = gap;

    for (var i = 0; i < values.length; i++) {
      final left = gap + i * gap * 2;
      final barH = chartHeight * values[i].clamp(0.0, 1.0);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, chartHeight - barH, barWidth, barH),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, barPaint);

      if (hasLabels) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels![i],
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: barWidth + gap);

        final labelX = left + barWidth / 2 - tp.width / 2;
        tp.paint(canvas, Offset(labelX, chartHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels;
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = const Color(0xFFFFE4E6);
    final linePaint = Paint()
      ..color = AppColors.alertPrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final gridPaint = Paint()
      ..color = const Color(0xFFECEEF3)
      ..strokeWidth = 1;

    for (var i = 0; i < 3; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - size.height * values[i].clamp(0.0, 1.0);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values;
}
