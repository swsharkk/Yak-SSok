import 'package:flutter/material.dart';

import '../services/behavior_log_service.dart';

/// Navigator 이벤트를 감지해 행동 점수를 기록하는 observer.
/// MaterialApp.navigatorObservers에 등록한다.
class BehaviorNavigatorObserver extends NavigatorObserver {
  BehaviorNavigatorObserver({required this.onEvent});

  final void Function(BehaviorEventType) onEvent;

  DateTime? _enterTime;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _enterTime = DateTime.now();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _recordDwell();
    onEvent(BehaviorEventType.backNavigation);
    _enterTime = DateTime.now();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _enterTime = DateTime.now();
  }

  void _recordDwell() {
    if (_enterTime == null) return;
    final seconds = DateTime.now().difference(_enterTime!).inSeconds;
    if (seconds > 30) onEvent(BehaviorEventType.longDwell);
  }
}
