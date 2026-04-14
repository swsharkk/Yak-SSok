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
```

### 2. 패키지 설치
터미널에서 아래 명령어를 실행하여 필요한 의존성 패키지를 설치합니다.

```bash
pip install fastapi uvicorn pydantic google-genai python-dotenv
```

### 3. 서버 실행
다음 명령어를 입력하여 서버를 실행합니다. `--reload` 옵션이 적용되어 있어 코드 수정 시 서버가 자동으로 재시작됩니다.

```bash
python -m uvicorn main:app --reload
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
