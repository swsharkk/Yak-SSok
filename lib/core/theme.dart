import 'package:flutter/material.dart';

/// 앱 전역 색상 팔레트.
/// 화면/위젯에서 색상 하드코딩 금지. 반드시 여기에서 가져다 쓴다.
class AppColors {
  AppColors._();

  // 기본
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);

  // 브랜드 (긴급 호출, 알림 등)
  static const Color brandRed = Color(0xFFE53E3E);
  static const Color brandRedDark = Color(0xFFC53030);
  static const Color brandRedSoft = Color(0xFFFEE2E2);

  // 진행 상황 카드 (teal)
  static const Color progressTeal = Color(0xFF14B8A6);
  static const Color progressTealDark = Color(0xFF0D9488);
  static const Color progressTealLight = Color(0xFF99F6E4);

  // 아침 약 (파랑)
  static const Color morningBg = Color(0xFFDBEAFE);
  static const Color morningPrimary = Color(0xFF2563EB);
  static const Color morningPrimaryDark = Color(0xFF1D4ED8);

  // 점심 약 (초록)
  static const Color lunchBg = Color(0xFFDCFCE7);
  static const Color lunchPrimary = Color(0xFF22C55E);
  static const Color lunchPrimaryDark = Color(0xFF16A34A);

  // 저녁 약 (보라) — 디자인 확정 시 조정
  static const Color eveningBg = Color(0xFFEDE9FE);
  static const Color eveningPrimary = Color(0xFF7C3AED);

  // 알림 / 지각 (빨강)
  static const Color alertBg = Color(0xFFFEE2E2);
  static const Color alertPrimary = Color(0xFFDC2626);
  static const Color alertPrimaryDark = Color(0xFFB91C1C);

  // 건강 요약
  static const Color hydrationBg = Color(0xFFFEF3C7);
  static const Color hydrationIcon = Color(0xFFD97706);
  static const Color stepsBg = Color(0xFFDBEAFE);
  static const Color stepsIcon = Color(0xFF2563EB);
  static const Color caloriesBg = Color(0xFFFFEDD5);
  static const Color caloriesIcon = Color(0xFFEA580C);

  // 달력 슬롯 색상
  static const Color calendarAmber = Color(0xFFF59E0B);

  // 소셜 로그인
  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color kakaoText = Color(0xFF191919);
  static const Color naverGreen = Color(0xFF03C75A);

  // 약 검색
  static const Color searchVoiceBg = Color(0xFFEFFFEF);
  static const Color searchVoiceIconBg = Color(0xFFBDF7C9);
  static const Color searchVoicePrimary = Color(0xFF009D55);
  static const Color searchCameraBg = Color(0xFFDDE5FF);
  static const Color searchCameraIconBg = Color(0xFFC9D6FF);
  static const Color searchCameraPrimary = Color(0xFF0F2F63);
  static const Color searchChatBg = Color(0xFFFFD9DC);
  static const Color searchChatIconBg = Color(0xFFFFE8EA);
  static const Color searchChatPrimary = Color(0xFF6F1233);
  static const Color searchRecentBlue = Color(0xFF006EDC);
  static const Color searchRecentGreen = Color(0xFF00894B);
  static const Color searchRecentRed = Color(0xFFB23A55);
  static const Color searchChevron = Color(0xFF718275);
}

/// 앱 전역 수치(여백/모서리/아이콘 크기 등). magic number 금지.
class AppDimensions {
  AppDimensions._();

  // 여백
  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 12;
  static const double paddingLg = 16;
  static const double paddingXl = 20;
  static const double paddingXxl = 24;

  // 모서리
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusPill = 999;

  // 아이콘
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // 카드 / 컴포넌트
  static const double cardPadding = 20;
  static const double medicineThumbSize = 64;
  static const double progressBarHeight = 8;
  static const double emergencyButtonHeight = 36;
  static const double bottomNavHeight = 64;
}

/// 앱 전역 텍스트 라벨. 다국어 도입 전까지 한국어 라벨을 모아둔다.
class AppStrings {
  AppStrings._();

  static const String appName = 'YAK-SSOK';
  static const String emergencyCall = '긴급 호출';
  static const String greetingMorning = '좋은 아침이에요,';
  static const String greetingDoingWell = '참 잘하고 계세요!';
  static const String todayProgress = '오늘의 진행 상황';
  static const String todayMedicine = '오늘의 약';
  static const String fullSchedule = '전체 일정';
  static const String todayHealthSummary = '오늘의 건강 요약';
  static const String hydration = '수분';
  static const String steps = '걸음';
  static const String calories = '칼로리';

  // 건강 정보 입력 화면
  static const String healthInfoTitle = '내 건강정보';
  static const String healthInfoBodySection = '신체 정보';
  static const String healthInfoHeight = '키';
  static const String healthInfoWeight = '몸무게';
  static const String healthInfoAge = '나이';
  static const String healthInfoGender = '성별';
  static const String healthInfoMale = '남성';
  static const String healthInfoFemale = '여성';
  static const String healthInfoWaterSection = '수분 목표';
  static const String healthInfoWaterGoal = '하루 목표';
  static const String healthInfoSave = '저장하기';

  // 검색
  static const String searchTitle = '약 찾기';
  static const String searchSubtitle = '어떻게 약을 검색할까요?';
  static const String voiceSearch = '음성 검색';
  static const String voiceSearchDescription = '말씀만 하시면\n찾아드려요';
  static const String cameraSearch = '카메라\n촬영';
  static const String cameraSearchDescription = '사진으로\n확인';
  static const String chatSearch = '챗봇 상\n담';
  static const String chatSearchDescription = '무엇이든\n질문';
  static const String recentSearchMedicine = '최근 검색한 약';
  static const String clearAll = '모두 지우기';
  static const String searchedAt = '검색일';

  // 약 슬롯
  static const String slotMorning = '아침 약';
  static const String slotLunch = '점심 약';
  static const String slotEvening = '저녁 약';
  static const String slotAlert = '알림';

  // 복약 액션
  static const String actionTaken = '복용 완료';
  static const String actionTake = '복용하기';
  static const String actionTakeNow = '지금 드세요';
  static const String missedMessage = '복용 시간을 놓쳤습니다!';

  // 달력
  static const String calendarTitle = '복약 달력';
  static const String calendarSubtitle = '모두 잘 드셨어요';
  static const String calendarScheduleSectionTitle = '오늘의 약 목록';
  static const String monthlyComplianceRate = '이달의 복용률';
  static const String consecutiveDays = '연속 복용일';
  static const String missedTimeSuffix = ' (지남)';
  static const String noScheduleForDay = '이 날 복약 일정이 없어요';
  static const String calendarTakeNow = '지금 복용';

  // 로그인
  static const String loginSubtitle = '의약품 인식해서 알려주는 서비스';
  static const String loginWithEmail = '이메일로 로그인';
  static const String loginWithKakao = '카카오 로그인';
  static const String loginWithNaver = '네이버 로그인';
  static const String emailHint = '이메일';
  static const String passwordHint = '비밀번호';
  static const String login = '로그인';
  static const String findAccount = '아이디/비밀번호 찾기';
  static const String signUp = '회원가입';
  static const String loginFailedMessage = '이메일 또는 비밀번호를 확인해주세요.';
  static const String socialLoginComingSoon = '준비 중인 서비스예요.';

  // 더보기
  static const String moreTitle = '설정 및 정보';
  static const String moreSavedMedicine = '내가 저장한 약';
  static const String moreHealthInfo = '건강 정보';
  static const String moreMyInfo = '내 정보';
  static const String moreSettings = '설정';
  static const String moreDailyQuoteTitle = '오늘의 한마디';
  static const List<String> moreDailyQuotes = [
    '매일 제때 약을 챙기는 것, 작은 습관이 큰 건강을 만듭니다. 오늘도 잘하고 계세요!',
    '건강은 하루아침에 만들어지지 않아요. 오늘의 작은 실천이 내일의 건강을 만듭니다.',
    '약을 빠짐없이 챙기는 것, 그게 바로 나를 아끼는 방법이에요.',
    '규칙적인 복약은 몸에게 보내는 가장 따뜻한 메시지예요.',
    '오늘도 건강을 위한 한 걸음을 내디뎠군요. 정말 대단해요!',
    '당신의 건강이 가장 소중한 자산입니다. 오늘도 꼬박꼬박 챙기세요.',
    '작은 습관의 힘을 믿으세요. 매일의 복약이 더 건강한 내일을 만들어요.',
  ];

  // 하단 탭
  static const String tabHome = '홈';
  static const String tabSearch = '검색';
  static const String tabCalendar = '달력';
  static const String tabMore = '더보기';
}

/// 앱 ThemeData. MaterialApp에서 [AppTheme.light]를 사용한다.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.progressTeal,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.progressTeal,
      surface: AppColors.surface,
      error: AppColors.alertPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'MaruBuri',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.progressTeal,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }

  /// 레벨 3 고대비 테마 — 순흑/순백 기반으로 가독성 극대화.
  static ThemeData get highContrast {
    const scheme = ColorScheme.light(
      primary: Color(0xFF0D9488),
      surface: Colors.white,
      error: Color(0xFFB91C1C),
    );
    return light.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: light.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: light.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      dividerColor: Colors.black26,
    );
  }
}
