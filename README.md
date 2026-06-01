# Yak-SSok (약쏙) - 지능형 의약품 관리 AI 백엔드 서버

노년층 맞춤형 의약품 관리 애플리케이션 'Yak-SSok'의 핵심 AI 기능을 담당하는 백엔드 서버입니다.
사용자가 촬영한 약 봉투 텍스트를 분석하여 구조화된 복용 정보를 추출하고, 식약처 공공데이터를 기반으로 한 AI 약사 상담 기능을 제공합니다.

## 🛠 Tech Stack
- **Language**: Python 3.10+
- **Framework**: FastAPI
- **AI Model**: Google Gemini 2.5 Flash (Structured Output 적용)
- **External API**: 공공데이터포털 식약처 의약품개요정보(e약은요) API
- **Tools**: uvicorn, pydantic, python-dotenv, requests

## 🚀 시작하기 (Installation & Setup)

프로젝트를 로컬 환경에서 실행하기 위한 설정 방법입니다.

### 1. 환경 변수 설정
프로젝트 루트 디렉토리에 `.env` 파일을 생성하고 발급받은 API 키를 입력합니다.
(보안상의 이유로 `.env` 파일은 깃허브 저장소에 포함되지 않으므로 직접 생성해야 합니다.)

`GOOGLE_API_KEY="본인의_구글_Gemini_API_키"`
`DATA_GO_KR_API_KEY="본인의_공공데이터포털_식약처_API_키(Decoding_Key)"`

### 2. 패키지 설치
터미널에서 아래 명령어를 실행하여 필요한 의존성 패키지를 설치합니다.

`pip install fastapi uvicorn pydantic google-genai python-dotenv requests`

### 3. 서버 실행
다음 명령어를 입력하여 서버를 실행합니다. `--reload` 옵션이 적용되어 있어 코드 수정 시 서버가 자동으로 재시작됩니다.

`python -m uvicorn server:app --reload`

서버가 성공적으로 실행되면 브라우저에서 `http://127.0.0.1:8000/docs` 로 접속하여 Swagger UI를 통해 모든 API를 직접 테스트할 수 있습니다.

---

## 📡 API Endpoints

### 1. 약 봉투 텍스트 파싱 API
- **Endpoint**: `[POST] /api/parse-prescription`
- **Description**: Google ML Kit 등을 통해 추출된 약국 영수증 생 텍스트(Raw Text)를 전달받아, 오타를 문맥에 맞게 교정하고 정확한 복용 정보(약 이름, 1일 복용 횟수, 총 투약 일수)를 구조화된 JSON 데이터로 반환합니다.
- **Request (Content-Type: text/plain)**:
`알마겔정`
`[산 관련 질환용 치료제]`
`심한 변비나 설사 나타날 경우 전문가와 상의하세요.`
`1`
`6`
`3`

- **Response (JSON)**:
`{`
`  "status": "success",`
`  "data": [`
`    {`
`      "drug_name": "알마겔정",`
`      "daily_frequency": 3,`
`      "duration_days": 6`
`    }`
`  ]`
`}`

### 2. AI 약사 상담 (RAG) 챗봇 API
- **Endpoint**: `[POST] /api/chat`
- **Description**: 식약처 공공데이터 API(e약은요)를 실시간으로 조회하여 정확한 효능, 용법, 주의사항 데이터를 검색(Retrieval)하고, 이를 바탕으로 노년층 사용자의 질문에 친절하고 다정한 전문 약사 페르소나로 답변을 생성합니다.
- **Request (Content-Type: application/json)**:
`{`
`  "question": "어르신이 드실 건데, 이 약 언제 먹는 게 좋은지 친절하게 설명해 주세요.",`
`  "context_drugs": [`
`    "알마겔정"`
`  ]`
`}`

- **Response (JSON)**:
`{`
`  "status": "success",`
`  "answer": "어르신, 안녕하세요! 친절한 AI 약사입니다. 처방받으신 '알마겔정'에 대해 설명해 드릴게요. 이 약은 위산 과다로 인한 속 쓰림을 완화해 주는 약이랍니다. 식후 1~2시간 후에 씹지 마시고 물과 함께 편안하게 드시면 됩니다. 혹시 변비가 심해지면 무리하지 마시고 꼭 다시 알려주세요! 건강이 최고입니다."`
`}`

## 🛡️ 예외 처리 (Error Handling)
안정적인 앱 서비스 운영을 위해 서버 과부하 상황에 대한 방어 로직이 적용되어 있습니다.
- **429 RESOURCE_EXHAUSTED**: AI 요청 한도 초과 시, 앱 다운을 방지하고 "약 1분 후 다시 시도해 주세요"라는 안내 메시지를 반환합니다.
- **503 UNAVAILABLE**: 구글 서버 트래픽 과부하 시, "접속자가 몰려 답변이 지연되고 있습니다"라는 안내 메시지를 반환합니다.