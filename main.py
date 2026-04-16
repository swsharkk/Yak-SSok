import firebase_admin
from firebase_admin import credentials
from fastapi import FastAPI

# 1. Firebase 초기화 (가장 먼저 실행되어야 합니다)
# 파일명이 dir 명령어로 확인한 이름과 정확히 일치하도록 설정했습니다.
try:
    cred = credentials.Certificate("yakssok-backend-firebase-adminsdk-fbsvc-15c58432ef.json")
    firebase_admin.initialize_app(cred)
    print("Firebase 초기화 성공!")
except Exception as e:
    print(f"Firebase 초기화 실패: {e}")

# 2. 초기화 완료 후 모듈 임포트
import authorization
import medi_calendar

app = FastAPI()

# --- 기본 접속 확인용 ---
@app.get("/")
async def root():
    return {"message": "백엔드 서버가 정상적으로 작동 중입니다."}

# --- 회원가입 및 인증 API ---
@app.post("/signup")
async def signup(email: str, role: str, nickname: str, password: str):
    return authorization.create_user(email, role, nickname, password)

# --- 로그인 API ---
@app.post("/login")
async def login(email: str, password: str):
    return authorization.verify_user(email, password)


@app.post("/connect/request")
async def connect_request(guardian_uid: str, target_code: str):
    return authorization.request_connection(guardian_uid, target_code)

# --- 캘린더 일정 생성 API ---
@app.post("/schedule/create")
async def make_schedule(uid: str, med_name: str, days: int):
    times = ["08:00", "13:00", "19:00"] # 기본적으로 하루 3회(아침, 점심, 저녁) 일정을 생성하도록 설정
    return medi_calendar.setup_medication_schedule(uid, med_name, days, times)

@app.post("/action/memo")
async def send_memo(elder_uid: str, memo_text: str):
    return authorization.update_elder_memo(elder_uid, memo_text)


@app.post("/connect/approve")
async def connect_approve(elder_uid: str, connection_id: str):
    return authorization.approve_connection(elder_uid, connection_id)

@app.patch("/calendar/take")
async def medication_take(elder_uid: str, schedule_id: str):
    return authorization.take_medication(elder_uid, schedule_id)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)

    