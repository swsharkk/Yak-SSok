/// 앱 전역 상수. API 키/URL 등 환경 의존 값은 --dart-define에서 주입.
class AppConstants {
  AppConstants._();

  // 식약처 공공데이터 API
  static const String moefBaseUrl =
      'http://apis.data.go.kr/1471000/DrbEasyDrugInfoService';

  /// 빌드 시 주입: flutter run --dart-define=MOEF_API_KEY=xxx
  static const String moefApiKey = String.fromEnvironment('MOEF_API_KEY');

  /// 백엔드 미정. 추후 REST 서버 URL이 확정되면 주입.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// 로그인 연동 전 백엔드 기능 테스트용 uid.
  /// 실행 예: --dart-define=BACKEND_TEST_UID=<elder_uid>
  static const String backendTestUid = String.fromEnvironment(
    'BACKEND_TEST_UID',
    defaultValue: 'demo-elder',
  );

  // 로컬 저장 키
  static const String storageKeyAuthUser = 'auth_user';
  static const String storageKeyMedicines = 'medicines';
  static const String storageKeySchedules = 'schedules';
}
