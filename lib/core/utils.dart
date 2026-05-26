/// 공통 유틸. 외부 의존 없이 가벼운 포맷터만 제공.
/// 필요해지면 intl 패키지로 교체할 것.
class AppFormat {
  AppFormat._();

  /// "09:45 AM" 형식.
  static String timeOfDay12h(DateTime t) {
    final hour24 = t.hour;
    final isPm = hour24 >= 12;
    final hour12 = ((hour24 + 11) % 12) + 1;
    final mm = t.minute.toString().padLeft(2, '0');
    final hh = hour12.toString().padLeft(2, '0');
    return '$hh:$mm ${isPm ? 'PM' : 'AM'}';
  }

  /// "2026년 4월" — 달력 헤더
  static String yearMonthKorean(DateTime d) => '${d.year}년 ${d.month}월';

  /// "4월 28일 월요일" — 일정 섹션 날짜
  static String dateKorean(DateTime d) {
    const weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    return '${d.month}월 ${d.day}일 ${weekdays[d.weekday % 7]}';
  }

  /// "08:00" — 24시간 포맷
  static String timeHHmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// 1234 -> "1,234"
  static String thousands(num value) {
    final s = value.toString();
    final neg = s.startsWith('-');
    final digits = neg ? s.substring(1) : s;
    final parts = digits.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    if (parts.length > 1) {
      buf
        ..write('.')
        ..write(parts[1]);
    }
    return neg ? '-$buf' : buf.toString();
  }
}
