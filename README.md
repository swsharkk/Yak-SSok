# 약쏙 (Yak-SSok)

캡스톤 프로젝트 — 시니어를 위한 스마트 복약 관리 앱입니다.

약 복용 알람, 약 및 약봉투 사진 촬영 시 AI가 약 정보를 자동 인식하는 기능을 제공합니다.
큰 글씨, 직관적인 UI 등 시니어가 쉽게 사용할 수 있도록 설계했습니다.

---

## 기술 스택

| 분류 | 기술 |
|---|---|
| Framework | Flutter (Dart) |
| 상태관리 | Riverpod (코드 생성 기반 `riverpod_annotation`) |
| 데이터 모델 | Freezed + json_serializable (불변 객체, 코드 생성) |
| 라우팅 | go_router (선언형 라우팅) |
| AI / ML | Google ML Kit (약봉투 OCR 텍스트 인식) |
| 음성 인식 | speech_to_text |
| 지도 | Google Maps Flutter |
| 네트워크 | Dio (REST API, 식약처 공공데이터 API) |
| 알림 | flutter_local_notifications |
| 로컬 저장 | shared_preferences |

---

## 주요 기능

**복약 관리**
- 시간대별(아침/점심/저녁/취침 전) 복약 일정 등록 및 알람
- 복약 달력으로 월별 복용 이력 시각화
- 복용률 및 연속 복용일 통계 제공

**약 검색**
- 음성으로 약 이름 검색
- 카메라로 약 또는 약봉투 촬영 시 AI(OCR)가 약 정보 자동 인식
- 챗봇 상담을 통한 약 정보 조회
- 식약처 공공데이터 API 연동

**약국 찾기**
- 현재 위치 기반 주변 약국 지도 표시
- 약국 목록, 거리, 전화 연결 제공

**복약 안전 경고**
- 함께 복용 시 위험한 약 조합 자동 감지 및 경고 알림

**시니어 친화 UX**
- 큰 글씨와 직관적인 레이아웃
- 긴급 호출 버튼 상시 노출

---

## 개발 환경

| | 요구 사항 |
|---|---|
| macOS | Flutter 3.x 이상, Xcode |
| Windows | Flutter 3.x 이상, Android Studio |

---

## 시작하기

**macOS (iOS 시뮬레이터)**

```bash
flutter pub get
flutter run
```

**Windows (Android 에뮬레이터)**

```bash
flutter pub get
flutter run -d android
```

> 모델이나 프로바이더를 수정한 경우 아래 명령어를 먼저 실행하세요.
> ```bash
> dart run build_runner build --delete-conflicting-outputs
> ```
# Yak-SSok - 약 봉투 분석 백엔드 서버

약 봉투 사진에서 추출한 텍스트를 분석하여 복용 정보를 구조화된 데이터(JSON)로 변환하는 백엔드 서버입니다.

## Tech Stack
- **Language**: Python 3.10+
- **Framework**: FastAPI
- **AI Model**: Google Gemini 2.5 Flash
- **Tools**: uvicorn, pydantic, python-dotenv

## 시작하기 (Installation & Setup)

프로젝트를 로컬 환경에서 실행하기 위한 설정 방법입니다.

### 1. 환경 변수 설정
프로젝트 루트 디렉토리에 `.env` 파일을 생성하고 발급받은 구글 API 키를 입력합니다.
(보안상의 이유로 `.env` 파일은 저장소에 포함되지 않으므로 직접 생성해야 합니다.)

```text
GOOGLE_API_KEY="본인의_구글_API_키"
PUBLIC_DATA_API_KEY="본인의 식약처_API_키"
```

### 2. 패키지 설치
터미널에서 아래 명령어를 실행하여 필요한 의존성 패키지를 설치합니다.

```bash
pip install fastapi uvicorn pydantic google-genai python-dotenv
```

### 3. 서버 실행
다음 명령어를 입력하여 서버를 실행합니다. `--reload` 옵션이 적용되어 있어 코드 수정 시 서버가 자동으로 재시작됩니다.

```bash
python -m uvicorn server:app --reload
```

## API Endpoints

### [POST] `/api/parse-prescription`
추출된 약국 영수증 텍스트를 전달받아 복용 정보를 분석하고 반환합니다.

- **Request Body**:
  ```json
  {
    "raw_text": "추출된 텍스트 내용..."
  }
  ```
- **Response**:
  ```json
  {
    "status": "success",
    "data": [
      {
        "drug_name": "약이름",
        "daily_frequency": 3,
        "duration_days": 7
      }
    ]
  }
  ```
