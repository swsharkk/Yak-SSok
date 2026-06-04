import os
import pandas as pd
import firebase_admin
import jwt
from firebase_admin import credentials, firestore
from fastapi import FastAPI, Query, Path, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

# --- 1. 구글 Firebase Admin SDK 마스터 초기화 ---
try:
    if not firebase_admin._apps:
        # 파일명이 다를 수 있으므로 폴더 내 json 파일명을 매핑할 것
        cred = credentials.Certificate("yakssok-backend-firebase-adminsdk-fbsvc-15c58432ef.json")
        firebase_admin.initialize_app(cred)
        print("✅ [성공] Firebase 인프라 마스터 초기화 완료!")
except Exception as e:
    print(f"⚠️ Firebase 초기화 건너뜀 또는 예외 에러: {e}")

# 하부 도메인 비즈니스 로직 모듈 임포트
import authorization
import medi_calendar

app = FastAPI(title="약속(Yak-SSok) 캡스톤 디자인 통합 백엔드 엔진")
security_gate = HTTPBearer()

# 크롬 웹 및 모바일 하이브리드 통신을 위한 CORS 보안 필터 해제 고정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- 2. JWT 인증 및 변조 검증 전담 의존성 미들웨어 ---
def get_current_user_by_jwt(credentials: HTTPAuthorizationCredentials = Depends(security_gate)) -> dict:
    """API 진입 전 HTTP Bearer Header 토큰을 원자적으로 분해 검증하는 미들웨어"""
    token = credentials.credentials
    try:
        # authorization 모듈에 등록해 둔 비밀키와 알고리즘으로 복호화 서명 검증 
        payload = jwt.decode(token, authorization.JWT_SECRET_KEY, algorithms=[authorization.JWT_ALGORITHM])
        if payload.get("type") != "access":
            raise HTTPException(status_code=401, detail="유효한 Access Token 규격이 아닙니다.")
        return payload  # 토큰 내부의 sub(uid), role, nickname 정보 반환
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="액세스 토큰의 유효 기간이 만료되었습니다.")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="변조되었거나 신뢰할 수 없는 인증 토큰입니다.")



# [기능 1] 오픈 인증 및 계정 관리 API (토큰 인증 필요 없음)

@app.get("/")
async def root_connection_check():
    return {"status": "success", "message": "백엔드 서버가 정상적으로 작동 중입니다."}

@app.post("/signup")
async def signup(email: str, role: str, nickname: str, password: str):
    return authorization.create_user(email, role, nickname, password)

@app.post("/login")
async def login(email: str, password: str):
    return authorization.verify_user(email, password)



# 계정 연동 및 승인 도메인 API (JWT 토큰 인증 필수)

@app.post("/connect/request")
async def connect_request(
    guardian_uid: str, 
    target_code: str, 
    current_user: dict = Depends(get_current_user_by_jwt)
):
    return authorization.request_connection(guardian_uid, target_code)

@app.post("/connect/approve")
async def connect_approve(
    elder_uid: str, 
    connection_id: str, 
    current_user: dict = Depends(get_current_user_by_jwt)
):
    return authorization.approve_connection(elder_uid, connection_id)



# [기능 3] 복약 캘린더 대시보드 및 상호작용 API ( JWT 토큰 인증 필수)

@app.post("/schedule/create")
async def make_schedule(
    uid: str, 
    med_name: str, 
    days: int, 
    current_user: dict = Depends(get_current_user_by_jwt)
):
    # 아침(08시), 점심(13시), 저녁(19시)의 고정 복약 가이드라인 자동 주입
    times = ["08:00", "13:00", "19:00"]
    return medi_calendar.setup_medication_schedule(uid, med_name, days, times)

@app.patch("/calendar/take")
async def medication_take(
    elder_uid: str, 
    schedule_id: str, 
    current_user: dict = Depends(get_current_user_by_jwt)
):
    return authorization.take_medication(elder_uid, schedule_id)

@app.post("/action/memo")
async def send_memo(
    elder_uid: str, 
    memo_text: str, 
    current_user: dict = Depends(get_current_user_by_jwt)
):
    return authorization.update_elder_memo(elder_uid, memo_text)



# 공공데이터 포털 데이터 연동 DUR 병용금기 필터링 API ( JWT 필수)

@app.get("/medication/verify-dur/{elder_uid}")
async def verify_medication_dur(
    elder_uid: str = Path(..., description="검증할 노인 사용자의 고유 UID"), 
    new_med_name: str = Query(..., description="새로 추가하려는 의약품 제품명"),
    current_user: dict = Depends(get_current_user_by_jwt)
):
    """
    [지능형 핵심 로직] 사용자가 약을 등록하기 전, 
    DB 내 복용 약 리스트를 전수 대조하여 공공데이터 기반 상호작용 충돌을 사전 필터링합니다.
    """
    # 아키텍처 연동 무결성을 위해 await 키워드와 함께 check_drug_interaction 비동기 체인 가동
    return await medi_calendar.check_drug_interaction(elder_uid, new_med_name)


# 프론트엔드 시연용 수파베이스(Supabase) 가짜 관문 가로채기

@app.post("/auth/v1/signup")
async def fake_supabase_signup(request: Request):
    try:
        body = await request.json()
        print("====== 📥 프론트엔드 가입 데이터 가로채기 성공! ======")
        print(f"가입 요청 이메일: {body.get('email')}")
        print(f"가입 요청 패스워드: {body.get('password')}")
        print("==================================================")
        
        return {
            "access_token": "fake_master_token_for_capstone",
            "token_type": "bearer",
            "user": {
                "id": "test-user-id-1234",
                "email": body.get("email"),
                "user_metadata": body.get("user_metadata", {})
            }
        }
    except Exception as e:
        return {"detail": str(e)}


@app.post("/auth/v1/token")
async def fake_supabase_login(request: Request):
    body = await request.json()
    return {
        "access_token": "fake_master_token_for_capstone",
        "token_type": "bearer",
        "user": {"id": "test-user-id-1234", "email": body.get("email")}
    }


# --- 6. Uvicorn 빌드 엔진 기동 인터페이스 ---
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
