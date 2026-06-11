import os
import csv
import json
import hashlib
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()

# 한국 표준시 (UTC+9)
KST = timezone(timedelta(hours=9))
from pathlib import Path as FilePath
from typing import Optional
from uuid import uuid4
import pandas as pd
import firebase_admin
import jwt
from firebase_admin import credentials, firestore
from fastapi import FastAPI, Query, Path, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, Field

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

MEDICINE_CSV_PATHS = [
    FilePath("data/medicines.csv"),
    FilePath("medicines.csv"),
]
_medicine_cache = None

app = FastAPI(title="약속(Yak-SSok) 캡스톤 디자인 통합 백엔드 엔진")
security_gate = HTTPBearer()


class ProfileUpdateRequest(BaseModel):
    nickname: Optional[str] = None
    name: Optional[str] = None


class SavedMedicineRequest(BaseModel):
    medicineName: str
    company: Optional[str] = None
    description: Optional[str] = None
    imageUrl: Optional[str] = None
    slot: str
    doseCount: int = 1
    frequencyType: str = "daily"
    daysOfWeek: Optional[list[int]] = None
    intervalDays: Optional[int] = None


class ScheduleCreateRequest(BaseModel):
    medicineId: Optional[str] = None
    medicineName: str
    company: Optional[str] = None
    description: Optional[str] = None
    imageUrl: Optional[str] = None
    scheduledAt: str
    slot: str
    doseCount: Optional[int] = None
    mealRelation: Optional[str] = None


class ChatRequest(BaseModel):
    uid: Optional[str] = None
    message: str
    context_drugs: list[str] = []


class OcrRequest(BaseModel):
    image_base64: str


class _DrugInfo(BaseModel):
    drug_name: str = Field(description="약이름(실제 식약처 등록 명칭)")
    daily_frequency: int = Field(description="1일 복용횟수(숫자)")
    duration_days: int = Field(description="총 투약일수(숫자)")


class _PrescriptionResult(BaseModel):
    drugs: list[_DrugInfo]


def _genai_client():
    key = os.getenv("GOOGLE_API_KEY")
    if not key:
        return None
    return genai.Client(api_key=key)


def _fetch_drug_info(drug_name: str) -> str:
    api_key = os.getenv("DATA_GO_KR_API_KEY")
    if not api_key:
        return "API 키 없음"
    try:
        url = "http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList"
        res = __import__("requests").get(url, params={
            "serviceKey": api_key, "itemName": drug_name,
            "type": "json", "numOfRows": 1, "pageNo": 1,
        }, timeout=5)
        items = res.json().get("body", {}).get("items")
        if items:
            d = items[0]
            return (f"[효능]\n{d.get('efcyQesitm','')}\n"
                    f"[용법]\n{d.get('useMethodQesitm','')}\n"
                    f"[주의사항]\n{d.get('atpnQesitm','')}")
        return "정보 없음"
    except Exception as e:
        return f"통신 오류: {e}"

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


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _date_from_iso(value: str) -> datetime:
    # KST(UTC+9)로 변환 — Flutter가 KST 날짜를 date 파라미터로 전송하므로 맞춰야 함
    return datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone(KST)


def _slot_time(slot: str) -> tuple[int, int]:
    return {
        "morning": (8, 0),
        "lunch": (12, 0),
        "evening": (18, 0),
        "bedtime": (21, 0),
    }.get(slot, (9, 0))


def _schedule_payload(row: dict) -> dict:
    return {
        "id": row.get("id") or row.get("schedule_id"),
        "medicine": {
            "id": row.get("medicine_id") or row.get("medicine_name") or "",
            "name": row.get("medicine_name") or "",
            "company": row.get("company"),
            "description": row.get("description"),
            "imageUrl": row.get("image_url"),
        },
        "scheduledAt": row.get("scheduled_at"),
        "slot": row.get("slot") or "custom",
        "status": row.get("status") or "pending",
        "doseCount": int(row["dose_count"]) if row.get("dose_count") not in (None, "") else None,
        "mealRelation": row.get("meal_relation"),
        "takenAt": row.get("taken_at"),
    }


def _saved_payload(row: dict) -> dict:
    return {
        "id": row.get("id"),
        "medicine_name": row.get("medicine_name") or "",
        "company": row.get("company"),
        "description": row.get("description"),
        "image_url": row.get("image_url"),
        "slot": row.get("slot") or "custom",
        "dose_count": int(row.get("dose_count") or 1),
        "created_at": row.get("created_at") or _now_iso(),
    }



# [기능 1] 오픈 인증 및 계정 관리 API (토큰 인증 필요 없음)

@app.get("/")
async def root_connection_check():
    return {"status": "success", "message": "백엔드 서버가 정상적으로 작동 중입니다."}

@app.post("/signup")
def signup(email: str, role: str, nickname: str, password: str, link_code: Optional[str] = None):
    elder = None
    if role == "guardian":
        if not link_code:
            return {"status": "fail", "message": "보호자 가입에는 인증 코드가 필요합니다."}
        elder = authorization.find_elder_by_link_code(link_code)
        if not elder:
            return {"status": "fail", "message": "유효하지 않은 인증 코드입니다."}

    result = authorization.create_user(email, role, nickname, password)

    if result.get("status") == "success" and role == "guardian" and elder:
        guardian_uid = result["user"]["uid"]
        authorization.link_guardian_to_elder(guardian_uid, elder["uid"])

    return result


@app.get("/link-code/my")
def get_my_link_code(current_user: dict = Depends(get_current_user_by_jwt)):
    uid = current_user["sub"]
    user_data = authorization.firestore_get("users", uid) or {}
    link_code = user_data.get("link_code")
    if not link_code:
        return {"status": "fail", "message": "인증 코드가 없습니다."}
    return {"status": "success", "data": {"link_code": link_code}}


@app.get("/guardian/elder")
def get_guardian_elder(current_user: dict = Depends(get_current_user_by_jwt)):
    guardian_uid = current_user["sub"]
    guardian_data = authorization.firestore_get("users", guardian_uid) or {}
    elder_uid = guardian_data.get("connected_with")

    if not elder_uid:
        return {"status": "fail", "message": "연동된 어르신이 없습니다."}

    elder_data = authorization.firestore_get("users", elder_uid) or {}

    today = datetime.now(KST).date().isoformat()
    rows = authorization.firestore_query("schedules", "uid", elder_uid, limit=500)
    today_rows = []
    for row in rows:
        raw = row.get("scheduled_at")
        if not raw:
            continue
        if _date_from_iso(raw).date().isoformat() == today:
            today_rows.append(row)
    today_rows.sort(key=lambda r: r.get("scheduled_at") or "")

    # 오늘 스케줄이 없으면 저장된 약 목록에서 오늘 가상 일정 생성
    if not today_rows:
        saved = authorization.firestore_query("saved_medicines", "uid", elder_uid, limit=100)
        today_date = datetime.now(KST).date()
        for med in saved:
            slot = med.get("slot", "morning")
            hour, minute = _slot_time(slot)
            scheduled = datetime(today_date.year, today_date.month, today_date.day,
                                 hour, minute, 0, tzinfo=KST)
            today_rows.append({
                "id": med.get("id", ""),
                "medicine_id": med.get("id", ""),
                "medicine_name": med.get("medicine_name", ""),
                "company": med.get("company"),
                "description": med.get("description"),
                "image_url": med.get("image_url"),
                "scheduled_at": scheduled.isoformat(),
                "slot": slot,
                "status": "pending",
                "dose_count": med.get("dose_count", 1),
                "meal_relation": None,
                "taken_at": None,
            })
        today_rows.sort(key=lambda r: r.get("scheduled_at") or "")

    total = len(today_rows)
    done = sum(1 for r in today_rows if r.get("status") == "taken")

    return {
        "status": "success",
        "data": {
            "elder": {
                "uid": elder_uid,
                "name": elder_data.get("name") or elder_data.get("nickname") or "어르신",
                "nickname": elder_data.get("nickname") or "어르신",
            },
            "today": {
                "total": total,
                "done": done,
                "schedules": [_schedule_payload(r) for r in today_rows],
            },
        },
    }

@app.post("/login")
def login(email: str, password: str):
    return authorization.verify_user(email, password)


@app.get("/profile")
def get_profile(current_user: dict = Depends(get_current_user_by_jwt)):
    uid = current_user["sub"]
    try:
        user_data = authorization.firestore_get("users", uid) or {}
    except Exception:
        user_data = {}

    nickname = user_data.get("nickname") or current_user.get("nickname")
    name = user_data.get("name") or nickname

    return {
        "status": "success",
        "data": {
            "id": uid,
            "nickname": nickname,
            "name": name,
            "avatarUrl": user_data.get("avatarUrl"),
        },
    }


@app.patch("/profile")
def update_profile(
    request: ProfileUpdateRequest,
    current_user: dict = Depends(get_current_user_by_jwt),
):
    uid = current_user["sub"]
    nickname = (request.nickname or current_user.get("nickname") or "").strip()
    name = (request.name or nickname).strip()
    authorization.firestore_patch("users", uid, {"nickname": nickname, "name": name})
    return {
        "status": "success",
        "data": {
            "id": uid,
            "nickname": nickname,
            "name": name,
            "avatarUrl": None,
        },
    }


def load_medicines():
    global _medicine_cache
    if _medicine_cache is not None:
        return _medicine_cache

    csv_path = next((path for path in MEDICINE_CSV_PATHS if path.exists()), None)
    if csv_path is None:
        _medicine_cache = []
        return _medicine_cache

    last_error = None
    for encoding in ("utf-8-sig", "cp949", "euc-kr"):
        try:
            with csv_path.open(encoding=encoding, newline="") as file:
                _medicine_cache = [dict(row) for row in csv.DictReader(file)]
            print(f"✅ [성공] 의약품 CSV 로드 완료: {csv_path} ({len(_medicine_cache)}건)")
            return _medicine_cache
        except UnicodeDecodeError as e:
            last_error = e

    raise RuntimeError(f"의약품 CSV 인코딩을 읽을 수 없습니다: {last_error}")


def pick(row: dict, *keys: str) -> str:
    for key in keys:
        value = (row.get(key) or "").strip()
        if value:
            return value
    return ""


def medicine_response(row: dict) -> dict:
    return {
        "id": pick(row, "itemSeq", "품목기준코드", "ITEM_SEQ", "id"),
        "name": pick(row, "itemName", "품목명", "ITEM_NAME", "name"),
        "company": pick(row, "entpName", "업체명", "ENTP_NAME", "company"),
        "imageUrl": pick(row, "itemImage", "이미지", "ITEM_IMAGE", "imageUrl"),
        "description": pick(row, "efcyQesitm", "효능", "EFCY_QESITM", "description"),
        "cautions": pick(row, "atpnQesitm", "주의사항", "ATPN_QESITM", "cautions"),
        "dosage": pick(row, "dosage", "용량", "useMethodQesitm", "USE_METHOD_QESITM"),
    }


@app.get("/medicines/search")
def search_medicines(
    query: str = Query(..., min_length=1, description="검색할 약 이름"),
    limit: int = Query(20, ge=1, le=50, description="최대 검색 개수"),
):
    keyword = query.strip()

    # medicines.csv 있으면 우선 사용
    medicines = load_medicines()
    if medicines:
        keyword_lower = keyword.lower()
        data = []
        for row in medicines:
            haystack = " ".join([
                pick(row, "itemSeq", "품목기준코드", "ITEM_SEQ", "id"),
                pick(row, "itemName", "품목명", "ITEM_NAME", "name"),
                pick(row, "entpName", "업체명", "ENTP_NAME", "company"),
            ]).lower()
            if keyword_lower in haystack:
                data.append(medicine_response(row))
                if len(data) >= limit:
                    break
        return {"status": "success", "data": data}

    # medicines.csv 없으면 DUR 데이터에서 제품명 검색 (A/B 양쪽 모두)
    dur = medi_calendar.dur_df
    if dur is None:
        return {"status": "success", "data": []}

    mask_a = dur["제품명A"].str.contains(keyword, na=False, regex=False)
    mask_b = dur["제품명B"].str.contains(keyword, na=False, regex=False)

    names_a = dur[mask_a][["제품명A", "업체명A"]].rename(columns={"제품명A": "name", "업체명A": "company"})
    names_b = dur[mask_b][["제품명B", "업체명B"]].rename(columns={"제품명B": "name", "업체명B": "company"})

    import pandas as _pd
    combined = _pd.concat([names_a, names_b]).drop_duplicates("name").head(limit)

    data = [
        {
            "id": f"dur_{i}",
            "name": row["name"],
            "company": row.get("company"),
            "imageUrl": None,
            "description": None,
            "cautions": None,
            "dosage": None,
        }
        for i, row in combined.iterrows()
    ]
    return {"status": "success", "data": data}


@app.get("/saved-medicines")
def saved_medicines(current_user: dict = Depends(get_current_user_by_jwt)):
    rows = authorization.firestore_query("saved_medicines", "uid", current_user["sub"])
    rows.sort(key=lambda row: row.get("created_at") or "", reverse=True)
    return {"status": "success", "data": [_saved_payload(row) for row in rows]}


@app.post("/saved-medicines")
def create_saved_medicine(
    request: SavedMedicineRequest,
    current_user: dict = Depends(get_current_user_by_jwt),
):
    # 같은 사용자+약이름이면 동일한 문서 ID로 묶어 중복 저장을 방지(업서트).
    key = f"{current_user['sub']}:{request.medicineName.strip()}"
    saved_id = "sm_" + hashlib.sha1(key.encode("utf-8")).hexdigest()
    now = _now_iso()
    existing = authorization.firestore_get("saved_medicines", saved_id)
    data = {
        "uid": current_user["sub"],
        "medicine_name": request.medicineName,
        "company": request.company,
        "description": request.description,
        "image_url": request.imageUrl,
        "slot": request.slot,
        "dose_count": request.doseCount,
        "frequency_type": request.frequencyType,
        "days_of_week": ",".join(map(str, request.daysOfWeek or [])),
        "interval_days": request.intervalDays,
        # 최초 저장 시각은 유지(재저장해도 목록 순서가 튀지 않게).
        "created_at": (existing or {}).get("created_at") or now,
    }
    saved = authorization.firestore_patch("saved_medicines", saved_id, data)

    # 최초 저장일 때만 오늘 일정을 생성한다(재저장 시 일정 중복 방지).
    if existing is None:
        hour, minute = _slot_time(request.slot)
        now_kst = datetime.now(KST)
        scheduled_at = now_kst.replace(
            hour=hour,
            minute=minute,
            second=0,
            microsecond=0,
        )
        # 슬롯 시간이 이미 지났으면 현재 시간으로 설정 (오늘 일정으로 표시)
        if scheduled_at < now_kst:
            scheduled_at = now_kst

        authorization.firestore_create(
            "schedules",
            {
                "uid": current_user["sub"],
                "medicine_id": saved_id,
                "medicine_name": request.medicineName,
                "company": request.company,
                "description": request.description,
                "image_url": request.imageUrl,
                "scheduled_at": scheduled_at.isoformat(),
                "slot": request.slot,
                "status": "pending",
                "dose_count": request.doseCount,
                "meal_relation": None,
                "taken_at": None,
                "created_at": now,
                "updated_at": now,
            },
            uuid4().hex,
        )

    return {"status": "success", "data": _saved_payload(saved)}


@app.delete("/saved-medicines/{medicine_id}")
def delete_saved_medicine(
    medicine_id: str,
    current_user: dict = Depends(get_current_user_by_jwt),
):
    authorization.firestore_delete("saved_medicines", medicine_id)
    return {"status": "success"}


@app.get("/schedules")
def list_schedules(
    date: Optional[str] = None,
    year: Optional[int] = None,
    month: Optional[int] = None,
    current_user: dict = Depends(get_current_user_by_jwt),
):
    rows = authorization.firestore_query("schedules", "uid", current_user["sub"], limit=500)
    filtered = []
    for row in rows:
        scheduled_raw = row.get("scheduled_at")
        if not scheduled_raw:
            continue
        scheduled = _date_from_iso(scheduled_raw)
        if date and scheduled.date().isoformat() != date:
            continue
        if year and month and (scheduled.year != year or scheduled.month != month):
            continue
        filtered.append(row)
    filtered.sort(key=lambda row: row.get("scheduled_at") or "")
    return {"status": "success", "data": [_schedule_payload(row) for row in filtered]}


@app.post("/schedules")
def create_schedule_v2(
    request: ScheduleCreateRequest,
    current_user: dict = Depends(get_current_user_by_jwt),
):
    schedule_id = uuid4().hex
    now = _now_iso()
    row = authorization.firestore_create(
        "schedules",
        {
            "uid": current_user["sub"],
            "medicine_id": request.medicineId or request.medicineName,
            "medicine_name": request.medicineName,
            "company": request.company,
            "description": request.description,
            "image_url": request.imageUrl,
            "scheduled_at": request.scheduledAt,
            "slot": request.slot,
            "status": "pending",
            "dose_count": request.doseCount,
            "meal_relation": request.mealRelation,
            "taken_at": None,
            "created_at": now,
            "updated_at": now,
        },
        schedule_id,
    )
    return {"status": "success", "data": _schedule_payload(row)}


@app.patch("/schedules/{schedule_id}/take")
def take_schedule(
    schedule_id: str,
    current_user: dict = Depends(get_current_user_by_jwt),
):
    row = authorization.firestore_patch(
        "schedules",
        schedule_id,
        {
            "status": "taken",
            "taken_at": _now_iso(),
            "updated_at": _now_iso(),
        },
    )
    return {"status": "success", "data": _schedule_payload(row)}


@app.delete("/schedules/{schedule_id}")
def delete_schedule(
    schedule_id: str,
    current_user: dict = Depends(get_current_user_by_jwt),
):
    authorization.firestore_delete("schedules", schedule_id)
    return {"status": "success"}


@app.post("/chat")
def chat(request: ChatRequest, current_user: dict = Depends(get_current_user_by_jwt)):
    client = _genai_client()
    if not client:
        return {"status": "error", "message": "AI 서비스 키가 설정되지 않았습니다."}

    retrieved = ""
    for drug in request.context_drugs:
        retrieved += f"--- {drug} ---\n{_fetch_drug_info(drug)}\n\n"

    prompt = (
        "너는 어르신들의 건강을 챙겨주는 친절하고 다정한 전문 약사 AI야.\n"
        f"[검색된 의약품 정보]\n{retrieved or '없음'}\n"
        f"[질문]\n{request.message}"
    )
    try:
        response = client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
        return {"status": "success", "reply": response.text}
    except Exception as e:
        err = str(e)
        if "429" in err or "RESOURCE_EXHAUSTED" in err:
            return {"status": "error", "message": "AI 요청이 너무 많습니다. 잠시 후 다시 시도해 주세요."}
        return {"status": "error", "message": err}


@app.post("/api/parse-prescription")
def parse_prescription(request: OcrRequest, current_user: dict = Depends(get_current_user_by_jwt)):
    import base64
    client = _genai_client()
    if not client:
        return {"status": "error", "message": "AI 서비스 키가 설정되지 않았습니다."}

    try:
        image_bytes = base64.b64decode(request.image_base64)
    except Exception:
        return {"status": "error", "message": "이미지 데이터가 올바르지 않습니다."}

    prompt = (
        "이 이미지는 약국 처방전 또는 약 봉투 사진이야.\n"
        "이미지에서 약 이름, 1일 복용횟수, 총 투약일수를 추출해줘.\n"
        "약 이름은 정확한 한국 식약처 등록 명칭으로 교정해줘.\n"
        "처방된 약이 없으면 drugs 배열을 빈 배열로 반환해."
    )
    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                types.Part.from_bytes(data=image_bytes, mime_type="image/jpeg"),
                types.Part.from_text(text=prompt),
            ],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=_PrescriptionResult,
                temperature=0.1,
            ),
        )
        parsed = json.loads(response.text)
        return {"status": "success", "data": parsed["drugs"]}
    except Exception as e:
        err = str(e)
        if "429" in err or "RESOURCE_EXHAUSTED" in err:
            return {"status": "error", "message": "AI 요청이 너무 많습니다. 잠시 후 다시 시도해 주세요."}
        return {"status": "error", "message": err}



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
    now = datetime.now(timezone.utc)
    created = []
    for day in range(days):
        for slot, (hour, minute) in {
            "morning": (8, 0),
            "lunch": (12, 0),
            "evening": (18, 0),
        }.items():
            scheduled_at = (now + timedelta(days=day)).replace(
                hour=hour,
                minute=minute,
                second=0,
                microsecond=0,
            )
            created.append(authorization.firestore_create(
                "schedules",
                {
                    "uid": uid,
                    "medicine_id": med_name,
                    "medicine_name": med_name,
                    "scheduled_at": scheduled_at.isoformat(),
                    "slot": slot,
                    "status": "pending",
                    "dose_count": 1,
                    "created_at": _now_iso(),
                    "updated_at": _now_iso(),
                },
                uuid4().hex,
            ))
    return {"status": "success", "data": [_schedule_payload(row) for row in created]}

@app.patch("/calendar/take")
async def medication_take(
    elder_uid: str, 
    schedule_id: str, 
    current_user: dict = Depends(get_current_user_by_jwt)
):
    row = authorization.firestore_patch(
        "schedules",
        schedule_id,
        {
            "status": "taken",
            "taken_at": _now_iso(),
            "updated_at": _now_iso(),
        },
    )
    return {"status": "success", "data": _schedule_payload(row)}

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
