import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary (Deep Teal) ──────────────────────────────────────────────────
  static const Color primary        = Color(0xFF14B8A6);
  static const Color primaryMedium  = Color(0xFF2DD4BF);
  static const Color primaryLight   = Color(0xFFCCFBF1);

  // ── Neutral ──────────────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF2F2F7);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceElevated= Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF1C1C1E);
  static const Color textSecondary  = Color(0xFF48484A);
  static const Color textMuted      = Color(0xFF8E8E93);
  static const Color divider        = Color(0xFFE5E5EA);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF34C759);
  static const Color warning        = Color(0xFFFF9F0A);
  static const Color error          = Color(0xFFFF3B30);
  static const Color info           = Color(0xFF007AFF);

  // ── Slot Accent (채도 낮춤) ──────────────────────────────────────────────
  static const Color morningAccent  = Color(0xFF4A90D9);
  static const Color lunchAccent    = Color(0xFF44A57C);
  static const Color eveningAccent  = Color(0xFFD4875A);
  static const Color bedtimeAccent  = Color(0xFF7B68C8);

  // ── Slot Chip 배경 ────────────────────────────────────────────────────────
  static const Color morningChipBg  = Color(0xFFEBF4FF);
  static const Color lunchChipBg    = Color(0xFFEBF7F2);
  static const Color eveningChipBg  = Color(0xFFFFF3EB);
  static const Color bedtimeChipBg  = Color(0xFFF3F0FF);
  static const Color alertChipBg    = Color(0xFFFFEBEB);

  // ── Emergency / Alert ────────────────────────────────────────────────────
  static const Color alertPrimary     = Color(0xFFFF3B30);
  static const Color alertPrimaryDark = Color(0xFFD70015);
  static const Color alertBg          = Color(0xFFFFF0EF);
  static const Color brandRed         = Color(0xFFFF3B30);
  static const Color brandRedSoft     = Color(0xFFFFEBEB);

  // ── Primary extras ───────────────────────────────────────────────────────
  static const Color primarySubtle  = Color(0xFFF0FDFA);

  // ── Progress (backward compat) ───────────────────────────────────────────
  static const Color progressTeal      = Color(0xFF14B8A6);
  static const Color progressTealDark  = Color(0xFF0D9488);
  static const Color progressTealLight = Color(0xFFCCFBF1);

  // ── Legacy slot (backward compat) ────────────────────────────────────────
  static const Color morningBg           = Color(0xFFEBF4FF);
  static const Color morningPrimary      = Color(0xFF4A90D9);
  static const Color morningPrimaryDark  = Color(0xFF2D6DB5);
  static const Color lunchBg             = Color(0xFFEBF7F2);
  static const Color lunchPrimary        = Color(0xFF44A57C);
  static const Color lunchPrimaryDark    = Color(0xFF2D7A58);
  static const Color eveningBg           = Color(0xFFF3F0FF);
  static const Color eveningPrimary      = Color(0xFF7B68C8);
  static const Color calendarAmber       = Color(0xFFFF9F0A);

  // ── Health Summary ───────────────────────────────────────────────────────
  static const Color hydrationBg   = Color(0xFFFFF8EC);
  static const Color hydrationIcon = Color(0xFFFF9F0A);
  static const Color stepsBg       = Color(0xFFEBF4FF);
  static const Color stepsIcon     = Color(0xFF4A90D9);
  static const Color caloriesBg    = Color(0xFFFFF0EB);
  static const Color caloriesIcon  = Color(0xFFD4875A);

  // ── Social Login ─────────────────────────────────────────────────────────
  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color kakaoText   = Color(0xFF191919);
  static const Color naverGreen  = Color(0xFF03C75A);

  // ── Search ───────────────────────────────────────────────────────────────
  static const Color searchVoiceBg       = Color(0xFFEBF7F2);
  static const Color searchVoiceIconBg   = Color(0xFFD1EFE3);
  static const Color searchVoicePrimary  = Color(0xFF2D7A58);
  static const Color searchCameraBg      = Color(0xFFEBF4FF);
  static const Color searchCameraIconBg  = Color(0xFFD1E5FF);
  static const Color searchCameraPrimary = Color(0xFF2D5FA6);
  static const Color searchChatBg        = Color(0xFFFFF0EB);
  static const Color searchChatIconBg    = Color(0xFFFFDDD1);
  static const Color searchChatPrimary   = Color(0xFFB04A25);
  static const Color searchRecentBlue    = Color(0xFF007AFF);
  static const Color searchRecentGreen   = Color(0xFF34C759);
  static const Color searchRecentRed     = Color(0xFFFF3B30);
  static const Color searchChevron       = Color(0xFFBCBCC0);
}

/// 그림자 시스템
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x07000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x3314B8A6),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32,
      offset: Offset(0, -4),
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x2814B8A6),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

class AppDimensions {
  AppDimensions._();

  static const double paddingXs  = 4;
  static const double paddingSm  = 8;
  static const double paddingMd  = 12;
  static const double paddingLg  = 16;
  static const double paddingXl  = 20;
  static const double paddingXxl = 24;
  static const double padding3xl = 32;

  static const double radiusSm   = 8;
  static const double radiusMd   = 12;
  static const double radiusLg   = 16;
  static const double radiusXl   = 20;
  static const double radiusPill = 999;

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  static const double cardPadding          = 16;
  static const double medicineThumbSize    = 40;
  static const double medicineCardHeight   = 72;
  static const double progressBarHeight    = 6;
  static const double emergencyButtonHeight = 36;
  static const double bottomNavHeight      = 64;
  static const double slotBarWidth         = 4;
}

class AppStrings {
  AppStrings._();

  static const String appName         = 'YAK-SSOK';
  static const String emergencyCall   = '긴급 호출';
  static const String greetingMorning = '좋은 아침이에요,';
  static const String greetingDoingWell = '참 잘하고 계세요!';
  static const String todayProgress  = '오늘의 진행 상황';
  static const String todayMedicine  = '오늘의 약';
  static const String fullSchedule   = '전체 일정';
  static const String todayHealthSummary = '오늘의 건강 요약';
  static const String hydration      = '수분';
  static const String steps          = '걸음';
  static const String calories       = '칼로리';

  static const String healthInfoTitle       = '내 건강정보';
  static const String healthInfoBodySection = '신체 정보';
  static const String healthInfoHeight      = '키';
  static const String healthInfoWeight      = '몸무게';
  static const String healthInfoAge         = '나이';
  static const String healthInfoGender      = '성별';
  static const String healthInfoMale        = '남성';
  static const String healthInfoFemale      = '여성';
  static const String healthInfoWaterSection = '수분 목표';
  static const String healthInfoWaterGoal   = '하루 목표';
  static const String healthInfoSave        = '저장하기';

  static const String searchTitle            = '약 찾기';
  static const String searchSubtitle         = '어떻게 약을 검색할까요?';
  static const String voiceSearch            = '음성 검색';
  static const String voiceSearchDescription = '말씀만 하시면 찾아드려요';
  static const String cameraSearch           = '카메라 촬영';
  static const String cameraSearchDescription = '사진으로 확인';
  static const String chatSearch             = '챗봇 상담';
  static const String chatSearchDescription  = '무엇이든 질문';
  static const String recentSearchMedicine   = '최근 검색한 약';
  static const String clearAll              = '모두 지우기';
  static const String searchedAt            = '검색일';

  static const String slotMorning = '아침 약';
  static const String slotLunch   = '점심 약';
  static const String slotEvening = '저녁 약';
  static const String slotBedtime = '취침 전';
  static const String slotAlert   = '알림';

  static const String actionTaken  = '복용완료';
  static const String actionTake   = '복용하기';
  static const String actionTakeNow = '지금 드세요';
  static const String missedMessage = '복용 시간을 놓쳤습니다!';

  static const String calendarTitle              = '복약 달력';
  static const String calendarSubtitle           = '모두 잘 드셨어요';
  static const String calendarScheduleSectionTitle = '오늘의 약 목록';
  static const String monthlyComplianceRate      = '이달의 복용률';
  static const String consecutiveDays            = '연속 복용일';
  static const String missedTimeSuffix           = ' (지남)';
  static const String noScheduleForDay           = '이 날 복약 일정이 없어요';
  static const String calendarTakeNow            = '지금 복용';

  static const String loginSubtitle         = '의약품 인식해서 알려주는 서비스';
  static const String loginWithEmail        = '이메일로 로그인';
  static const String loginWithKakao        = '카카오 로그인';
  static const String loginWithNaver        = '네이버 로그인';
  static const String emailHint             = '이메일';
  static const String passwordHint          = '비밀번호';
  static const String login                 = '로그인';
  static const String findAccount           = '아이디/비밀번호 찾기';
  static const String signUp                = '회원가입';
  static const String loginFailedMessage    = '이메일 또는 비밀번호를 확인해주세요.';
  static const String socialLoginComingSoon = '준비 중인 서비스예요.';

  static const String moreTitle          = '설정 및 정보';
  static const String moreSavedMedicine  = '내가 저장한 약';
  static const String moreHealthInfo     = '건강 정보';
  static const String moreMyInfo         = '내 정보';
  static const String moreSettings       = '설정';
  static const List<String> moreDailyQuotes = [
    '매일 제때 약을 챙기는 것, 작은 습관이 큰 건강을 만듭니다. 오늘도 잘하고 계세요!',
    '건강은 하루아침에 만들어지지 않아요. 오늘의 작은 실천이 내일의 건강을 만듭니다.',
    '약을 빠짐없이 챙기는 것, 그게 바로 나를 아끼는 방법이에요.',
    '규칙적인 복약은 몸에게 보내는 가장 따뜻한 메시지예요.',
    '오늘도 건강을 위한 한 걸음을 내디뎠군요. 정말 대단해요!',
    '당신의 건강이 가장 소중한 자산입니다. 오늘도 꼬박꼬박 챙기세요.',
    '작은 습관의 힘을 믿으세요. 매일의 복약이 더 건강한 내일을 만들어요.',
  ];
  static const String moreDailyQuoteTitle = '오늘의 한마디';

  static const String tabHome     = '홈';
  static const String tabSearch   = '검색';
  static const String tabCalendar = '달력';
  static const String tabMore     = '더보기';
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'MaruBuri',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'MaruBuri',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

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
