 주요 기능

① 사용자 관리 및 역할 분담 (POST /signup)
●다중 역할 지원: 사용자 가입 시 elder(노인)와 guardian(보호자) 역할을 구분하여 저장합니다.
●닉네임 시스템: role뿐만 아니라 실제 성함(nickname)을 데이터베이스에 귀속시켜 관리 효율성을 높였습니다.
●랜덤 링크 코드 생성: 노인 계정 생성 시에만 보호자와 연결할 수 있는 6자리 고유 인증 코드가 자동 발급됩니다.

② 계정 연동 및 승인 시스템 (Connection Logic)
●연결 요청 (POST /connect/request): 보호자가 노인의 코드를 입력하면 대기 상태(pending)로 연결 문서가 생성됩니다.
●상호 승인 (POST /connect/approve): 노인이 승인 시, 두 사용자의 문서에 서로의 UID를 기록(connected_with)하여 양방향 매칭을 완료합니다.

③ 복약 스케줄링 자동화 (POST /schedule/create)
●일정 분할 알고리즘: 복약 일수(days)를 입력받아 하루 3회(아침, 점심, 저녁)의 구체적인 시간대별 데이터를 자동으로 생성합니다.
●상태 관리: 각 일정마다 is_taken(복용 여부) 필드를 기본 False로 설정하여 추적 가능하게 설계했습니다.

④ 실시간 복약 확인 및 알림 (PATCH /calendar/take)
●상태 업데이트: 노인이 약을 먹고 버튼을 누르면 해당 일정의 is_taken을 True로 변경하고 복용 시간을 기록합니다.
●보호자 실시간 알림: 연결된 보호자의 interaction 컬렉션에 노인의 성함을 포함한 메시지(last_event)를 즉시 업데이트합니다.

기술 스택
●Framework: FastAPI (Python)
●Database: Google Firebase (Firestore)
●Authentication: Firebase Auth
●Server: Uvicorn

시작하기
1. 필수 조건
●Python 3.8 이상
●Firebase 서비스 계정 키 파일 (serviceAccountKey.json)

2. 설치 방법
먼저 저장소를 클론한 후, 필요한 라이브러리를 설치합니다.
# 저장소 클론
git clone [저장소 주소]
cd [프로젝트 폴더명]

# 가상환경 생성 및 활성화 (선택 사항)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 라이브러리 설치
pip install -r requirements.txt


3. 환경 설정
보안을 위해 Firebase 키 파일은 GitHub에 포함되어 있지 않습니다.
●백엔드 담당자에게 받은 serviceAccountKey.json 파일을 프로젝트 루트 폴더에 넣어주세요.

4. 서버 실행
python -m uvicorn main:app --reload

서버가 실행되면 다음 주소에서 API 명세를 확인할 수 있습니다.
●Swagger UI: http://127.0.0.1:8000/docs
 프로젝트 구조

├── main.py              # 서버 진입점 및 API 엔드포인트
├── auth.py              # 인증 관련 로직
├── database.py          # Firebase 연결 설정
├── requirements.txt     # 의존성 라이브러리 목록
├── README.md            # 프로젝트 가이드
└── serviceAccountKey.json  # (로컬 전용) Firebase 키 파일

___________________참고사항_____________________ 
1.	API 테스트: Swagger UI(.../docs)에서 각 기능을 직접 테스트해 볼 수 있습니다.
2.	보안 주의: serviceAccountKey.json 파일이 실수로 GitHub에 업로드되지 않도록 주의해 주세요. (현재 .gitignore에 등록됨)

