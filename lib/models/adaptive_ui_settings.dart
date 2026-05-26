/// 적응형 UI 3단계 레벨.
enum AdaptiveLevel {
  normal,      // 기본 — 변경 없음
  comfortable, // 편의 — 글자·버튼 확대
  accessible,  // 접근성 — 최대 확대 + 고대비 + 레이아웃 단순화
}

/// 현재 레벨에서 파생되는 UI 설정값 모음.
class AdaptiveUISettings {
  const AdaptiveUISettings({this.level = AdaptiveLevel.normal});

  final AdaptiveLevel level;

  double get textScale => const [1.0, 1.2, 1.5][level.index];
  double get buttonScale => const [1.0, 1.3, 1.5][level.index];
  bool get highContrast => level == AdaptiveLevel.accessible;
  bool get simplifiedLayout => level == AdaptiveLevel.accessible;

  AdaptiveUISettings copyWith({AdaptiveLevel? level}) =>
      AdaptiveUISettings(level: level ?? this.level);
}
