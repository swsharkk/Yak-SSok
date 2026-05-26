import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/adaptive_ui_provider.dart';

part 'behavior_log_service.g.dart';

enum BehaviorEventType {
  longDwell,      // 화면 30초 이상 체류 → +10점
  backNavigation, // 뒤로가기 → +8점
  tapRetry,       // 같은 버튼 재시도 → +15점
}

// 레벨별 업그레이드 임계 점수 [normal→comfortable, comfortable→accessible]
const _kThresholds = [30, 60];

@Riverpod(keepAlive: true)
class BehaviorLogService extends _$BehaviorLogService {
  @override
  int build() => 0; // 세션 누적 점수

  void logEvent(BehaviorEventType type) {
    final points = switch (type) {
      BehaviorEventType.longDwell => 10,
      BehaviorEventType.backNavigation => 8,
      BehaviorEventType.tapRetry => 15,
    };
    state = state + points;
    _checkUpgrade();
  }

  void reset() => state = 0;

  void _checkUpgrade() {
    final current =
        ref.read(adaptiveUIControllerProvider).valueOrNull;
    if (current == null) return;
    final idx = current.level.index;
    if (idx >= _kThresholds.length) return;
    if (state >= _kThresholds[idx]) {
      ref.read(adaptiveUIControllerProvider.notifier).upgradeLevel();
    }
  }
}
