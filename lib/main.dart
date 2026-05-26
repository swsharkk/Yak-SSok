import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await NotificationService.requestPermission();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase 초기화 실패: $e');
  }

  try {
    await FlutterNaverMap().init(
      clientId: 'j6tn20kmdo',
      onAuthFailed: (ex) => debugPrint('네이버 지도 인증 실패: $ex'),
    );
  } catch (e) {
    debugPrint('네이버 지도 초기화 실패: $e');
  }

  runApp(
    const ProviderScope(
      child: YakssokApp(),
    ),
  );
}
