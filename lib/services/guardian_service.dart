import 'package:dio/dio.dart';

import '../core/constants.dart';
import 'backend_auth_service.dart';

class GuardianElderInfo {
  const GuardianElderInfo({
    required this.uid,
    required this.name,
    required this.nickname,
  });
  final String uid;
  final String name;
  final String nickname;
}

class GuardianScheduleItem {
  const GuardianScheduleItem({
    required this.id,
    required this.medicineName,
    required this.doseCount,
    required this.slot,
    required this.scheduledAt,
    required this.rawStatus,
    this.takenAt,
  });

  final String id;
  final String medicineName;
  final int doseCount;
  final String slot;
  final String scheduledAt;
  final String rawStatus;
  final String? takenAt;

  bool get isDone => rawStatus == 'taken';
  bool get isMissed {
    if (isDone) return false;
    final dt = DateTime.tryParse(scheduledAt);
    return dt != null && dt.isBefore(DateTime.now());
  }
  bool get isPending => !isDone && !isMissed;

  String get slotLabel {
    switch (slot) {
      case 'morning':
        return '아침';
      case 'lunch':
        return '점심';
      case 'evening':
        return '저녁';
      case 'bedtime':
        return '취침';
      default:
        return slot;
    }
  }

  String get slotTime {
    switch (slot) {
      case 'morning':
        return '08:00';
      case 'lunch':
        return '12:00';
      case 'evening':
        return '18:00';
      case 'bedtime':
        return '21:00';
      default:
        return '';
    }
  }
}

class GuardianElderStatus {
  const GuardianElderStatus({
    required this.elder,
    required this.total,
    required this.done,
    required this.schedules,
  });
  final GuardianElderInfo elder;
  final int total;
  final int done;
  final List<GuardianScheduleItem> schedules;
}

class GuardianService {
  static Dio get _dio => Dio(BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 8),
      ));

  static Future<GuardianElderStatus?> getElderStatus() async {
    final options = await BackendAuthService.authOptions();
    if (options == null) throw Exception('로그인이 필요합니다.');

    final response = await _dio.get<Map<String, dynamic>>(
      '/guardian/elder',
      options: options,
    );

    final body = response.data ?? {};
    if (body['status'] != 'success') {
      final msg = body['message']?.toString() ?? '';
      if (msg.contains('연동') || msg.contains('어르신이 없')) return null;
      throw Exception(msg.isEmpty ? '데이터를 불러올 수 없습니다.' : msg);
    }

    final data = body['data'] as Map<String, dynamic>;
    final elderMap = data['elder'] as Map<String, dynamic>;
    final todayMap = data['today'] as Map<String, dynamic>;
    final list =
        (todayMap['schedules'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return GuardianElderStatus(
      elder: GuardianElderInfo(
        uid: elderMap['uid'] as String? ?? '',
        name: elderMap['name'] as String? ?? '어르신',
        nickname: elderMap['nickname'] as String? ?? '어르신',
      ),
      total: todayMap['total'] as int? ?? 0,
      done: todayMap['done'] as int? ?? 0,
      schedules: list.map((s) {
        final med = s['medicine'] as Map<String, dynamic>? ?? {};
        return GuardianScheduleItem(
          id: s['id'] as String? ?? '',
          medicineName: med['name'] as String? ?? '',
          doseCount: (s['doseCount'] as int?) ?? 1,
          slot: s['slot'] as String? ?? '',
          scheduledAt: s['scheduledAt'] as String? ?? '',
          rawStatus: s['status'] as String? ?? 'pending',
          takenAt: s['takenAt'] as String?,
        );
      }).toList(),
    );
  }

  static Future<String> getMyLinkCode() async {
    final options = await BackendAuthService.authOptions();
    if (options == null) throw Exception('로그인이 필요합니다.');

    final response = await _dio.get<Map<String, dynamic>>(
      '/link-code/my',
      options: options,
    );
    final body = response.data ?? {};
    if (body['status'] != 'success') {
      throw Exception(body['message']?.toString() ?? '코드를 불러올 수 없습니다.');
    }
    return (body['data'] as Map<String, dynamic>)['link_code'] as String;
  }
}
