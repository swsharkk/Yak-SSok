# Copilot Instructions — Yak-ssok Flutter Project

## 코드 작성 전 필수 절차
- 화면(Screen) 구현 시작 전에 반드시 생성할 Widget 파일 목록을 먼저 제시하고 확인받은 뒤 작성
- Screen 파일은 Scaffold + 최상위 레이아웃 뼈대만 담당. 세부 섹션·카드·리스트 아이템은 별도 Widget 파일로 분리
- 분리 기준: 반복 UI 단위, 독립 섹션, 조건부 블록, 재사용 가능 컴포넌트 → 각각 별도 파일

## 파일 구조
```
lib/features/{feature}/
  screens/   → 페이지 뼈대 (Scaffold, 최상위 Column/Row)
  widgets/   → 분리된 UI 조각들
  providers/ → Riverpod provider
  models/    → freezed 데이터 클래스
lib/shared/widgets/ → 2개 이상 feature에서 공유
```

## Widget 규칙
- StatelessWidget 우선. 내부 setState 필요할 때만 StatefulWidget
- const 생성자 항상 사용
- build() 80줄 초과 금지 → 초과 시 별도 Widget 파일로 분리
- build() 안에 API 호출·비즈니스 로직 금지

## 상태관리 (Riverpod)
- Widget에서 직접 API 호출 금지. 반드시 provider 경유
- @riverpod annotation 사용
- 비동기 상태는 AsyncValue<T> 사용

## 하드코딩 금지
- Color(0xFF...) 직접 사용 금지 → AppTheme / ColorScheme 참조
- 숫자·문자열 리터럴 직접 사용 금지 → core/constants/ 에 상수 정의
- API 엔드포인트: core/constants/api_constants.dart
- 여백·크기: core/constants/app_dimensions.dart

## 데이터 모델
- API 응답은 반드시 freezed 클래스로 변환. Map<String, dynamic> 직접 사용 금지
- 모델 파일 1개 = 클래스 1개

## 비동기
- async/await 사용. .then() 체인 금지
- StatefulWidget async 작업 후 반드시 `if (!mounted) return;` 체크

## Git
- main, dev 브랜치 직접 push 금지
- 커밋 메시지: feat: / fix: / chore: / refactor: 형식
