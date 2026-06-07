import hashlib
import random
import string
import uuid
from firebase_admin import firestore
import jwt
from datetime import datetime, timedelta
from typing import Optional
import requests
from google.auth.transport.requests import Request
from google.oauth2 import service_account

# Firestore 데이터베이스 클라이언트 초기화
db = firestore.client()

# 2. JWT 암호화 환경 변수 및 설정값 선언 
JWT_SECRET_KEY = "yakssok_capstone_secret_master_key_key_key"  # 상용 배포 시 환경변수 관리 권장
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_WEEKS = 2
SERVICE_ACCOUNT_FILE = "yakssok-backend-firebase-adminsdk-fbsvc-15c58432ef.json"
FIRESTORE_PROJECT_ID = "yakssok-backend"
FIRESTORE_BASE_URL = (
    f"https://firestore.googleapis.com/v1/projects/{FIRESTORE_PROJECT_ID}"
    "/databases/(default)/documents"
)
_rest_credentials = None


def _rest_headers():
    global _rest_credentials
    if _rest_credentials is None:
        _rest_credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE,
            scopes=["https://www.googleapis.com/auth/datastore"],
        )
    if not _rest_credentials.valid:
        _rest_credentials.refresh(Request())
    return {"Authorization": f"Bearer {_rest_credentials.token}"}


def _to_firestore_value(value):
    if value is None:
        return {"nullValue": None}
    if isinstance(value, bool):
        return {"booleanValue": value}
    if isinstance(value, int):
        return {"integerValue": str(value)}
    return {"stringValue": str(value)}


def _to_firestore_fields(data):
    return {key: _to_firestore_value(value) for key, value in data.items()}


def _from_firestore_fields(fields):
    data = {}
    for key, value in fields.items():
        if "stringValue" in value:
            data[key] = value["stringValue"]
        elif "integerValue" in value:
            data[key] = int(value["integerValue"])
        elif "booleanValue" in value:
            data[key] = value["booleanValue"]
        elif "nullValue" in value:
            data[key] = None
    return data


def _find_user_by_email(email):
    body = {
        "structuredQuery": {
            "from": [{"collectionId": "users"}],
            "where": {
                "fieldFilter": {
                    "field": {"fieldPath": "email"},
                    "op": "EQUAL",
                    "value": {"stringValue": email},
                }
            },
            "limit": 1,
        }
    }
    response = requests.post(
        f"{FIRESTORE_BASE_URL}:runQuery",
        headers=_rest_headers(),
        json=body,
        timeout=10,
    )
    response.raise_for_status()
    for item in response.json():
        document = item.get("document")
        if document:
            return _from_firestore_fields(document.get("fields", {}))
    return None


def firestore_create(collection: str, data: dict, document_id: Optional[str] = None) -> dict:
    if document_id is None:
        document_id = uuid.uuid4().hex
    response = requests.post(
        f"{FIRESTORE_BASE_URL}/{collection}",
        headers=_rest_headers(),
        params={"documentId": document_id},
        json={"fields": _to_firestore_fields(data)},
        timeout=10,
    )
    response.raise_for_status()
    return {**data, "id": document_id}


def firestore_patch(collection: str, document_id: str, data: dict) -> dict:
    # updateMask 지정해야 기존 필드가 유지됨 (없으면 문서 전체 덮어씌움)
    params = [("updateMask.fieldPaths", key) for key in data.keys()]
    response = requests.patch(
        f"{FIRESTORE_BASE_URL}/{collection}/{document_id}",
        headers=_rest_headers(),
        params=params,
        json={"fields": _to_firestore_fields(data)},
        timeout=10,
    )
    response.raise_for_status()
    return {**data, "id": document_id}


def firestore_delete(collection: str, document_id: str) -> None:
    response = requests.delete(
        f"{FIRESTORE_BASE_URL}/{collection}/{document_id}",
        headers=_rest_headers(),
        timeout=10,
    )
    if response.status_code not in (200, 404):
        response.raise_for_status()


def firestore_get(collection: str, document_id: str) -> Optional[dict]:
    response = requests.get(
        f"{FIRESTORE_BASE_URL}/{collection}/{document_id}",
        headers=_rest_headers(),
        timeout=10,
    )
    if response.status_code == 404:
        return None
    response.raise_for_status()
    data = response.json()
    fields = data.get("fields", {})
    if not fields:
        return None
    result = _from_firestore_fields(fields)
    result["id"] = document_id
    return result


def firestore_query(collection: str, field: str, value: str, limit: int = 100) -> list[dict]:
    body = {
        "structuredQuery": {
            "from": [{"collectionId": collection}],
            "where": {
                "fieldFilter": {
                    "field": {"fieldPath": field},
                    "op": "EQUAL",
                    "value": {"stringValue": value},
                }
            },
            "limit": limit,
        }
    }
    response = requests.post(
        f"{FIRESTORE_BASE_URL}:runQuery",
        headers=_rest_headers(),
        json=body,
        timeout=10,
    )
    response.raise_for_status()
    rows = []
    for item in response.json():
        document = item.get("document")
        if not document:
            continue
        data = _from_firestore_fields(document.get("fields", {}))
        data["id"] = document["name"].split("/")[-1]
        rows.append(data)
    return rows

def find_elder_by_link_code(code: str) -> Optional[dict]:
    """link_code로 어르신 계정을 조회합니다."""
    rows = firestore_query("users", "link_code", code.upper().strip(), limit=1)
    return rows[0] if rows else None


def link_guardian_to_elder(guardian_uid: str, elder_uid: str) -> None:
    """보호자 계정에 연동된 어르신 uid를 저장합니다."""
    firestore_patch("users", guardian_uid, {
        "connected_with": elder_uid,
        "status": "linked",
    })


def hash_password(password: str):
    """
    SHA-256 알고리즘을 활용하여 비밀번호 원문을 안전한 암호문으로 단방향 해싱합니다.
    """
    return hashlib.sha256(password.encode()).hexdigest()

# 보안 회원가입 및 고유 인증 코드 발급
def create_user(email, role, nickname, password):
    """
    새로운 사용자를 생성하고, 노인(elder) 계정일 경우 보호자 연동용 6자리 난수 코드를 발급합니다.
    """
    try:
        # 이메일 중복 체크
        existing_user = _find_user_by_email(email)
        if existing_user:
            return {"status": "fail", "message": "이미 존재하는 이메일입니다."}

        uid = uuid.uuid4().hex
        
        user_data = {
            "uid": uid,
            "email": email,
            "role": role,
            "nickname": nickname,
            "password": hash_password(password),  # 단방향 암호화 적용
            "connected_with": None,
            "status": "unlinked"
        }
        
        # 어르신 계정일 경우에만 6자리 영문 대문자+숫자 랜덤 코드 생성
        if role == "elder":
            link_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            user_data["link_code"] = link_code
            
        response = requests.post(
            f"{FIRESTORE_BASE_URL}/users",
            headers=_rest_headers(),
            params={"documentId": uid},
            json={"fields": _to_firestore_fields(user_data)},
            timeout=10,
        )
        response.raise_for_status()
        return {"status": "success", "message": "회원가입이 완료되었습니다.", "user": user_data}
        
    except Exception as e:
        return {"status": "error", "message": f"회원가입 중 오류 발생: {str(e)}"}

# 로그인 및 권한 검증 시스템
def verify_user(email, password):
    """
    입력된 이메일과 비밀번호를 검증하여 로그인 상태와 유저 권한(role)을 확인하고,
    보안 인가 처리를 위한 이중 JWT 토큰(Access/Refresh)을 발급하여 반환
    """
    try:
        data = _find_user_by_email(email)
        if not data:
            return {"status": "fail", "message": "존재하지 않는 이메일 계정입니다."}

        # 저장된 해시 비밀번호와 입력된 비밀번호의 해시값 대조
        if data["password"] == hash_password(password):
            tokens = create_tokens(data["uid"], data["role"], data["nickname"])
            return {
                "status": "success",
                "message": "로그인 성공 및 보안 인증 토큰 발급 완료",
                "tokens": tokens,
                "user_info": {
                    "uid": data["uid"],
                    "role": data["role"],
                    "nickname": data["nickname"],
                    "name": data.get("name") or data["nickname"],
                }
            }

        return {"status": "fail", "message": "비밀번호가 일치하지 않습니다."}
            
    except Exception as e:
        return {"status": "error", "message": f"로그인 처리 중 오류 발생: {str(e)}"}

# 보호자-노인 계정 연동 및 상호 승인 로직
def request_connection(guardian_uid, target_code):
    """
    보호자가 노인의 6자리 코드를 입력하여 '연결 대기(pending)' 문서 및 큐를 생성합니다.
    """
    try:
        # 코드로 해당 노인 찾기
        elder_query = db.collection("users").where("link_code", "==", target_code).stream()
        elder_uid = None
        
        for doc in elder_query:
            elder_uid = doc.to_dict().get("uid")
            
        if not elder_uid:
            return {"status": "fail", "message": "유효하지 않은 연동 코드입니다."}
            
        # connections 컬렉션에 승인 대기 상태로 등록
        db.collection("connections").add({
            "elder_uid": elder_uid,
            "guardian_uid": guardian_uid,
            "status": "pending"
        })
        return {"status": "success", "message": "보호자 연결 요청 완료 (어르신 승인 대기 중)"}
        
    except Exception as e:
        return {"status": "error", "message": f"연결 요청 중 오류 발생: {str(e)}"}

def approve_connection(elder_uid, connection_id):
    """
    노인이 연결 요청을 최종 승인하면 상호 connected_with 권한을 부여하고 매칭을 완료합니다.
    """
    try:
        conn_ref = db.collection("connections").document(connection_id)
        conn_data = conn_ref.get().to_dict()
        
        if not conn_data:
            return {"status": "fail", "message": "존재하지 않는 연결 요청입니다."}
            
        guardian_uid = conn_data.get("guardian_uid")
        
        # 1. 연결 상태를 linked로 업데이트
        conn_ref.update({"status": "linked"})
        
        # 2. 노인과 보호자 각자 문서의 connected_with 및 상태 필드 동시 업데이트
        db.collection("users").document(elder_uid).update({
            "connected_with": guardian_uid,
            "status": "linked"
        })
        db.collection("users").document(guardian_uid).update({
            "connected_with": elder_uid,
            "status": "linked"
        })
        
        return {"status": "success", "message": "보호자-사용자 상호 계정 연동 및 승인 완료!"}
        
    except Exception as e:
        return {"status": "error", "message": f"연결 승인 중 오류 발생: {str(e)}"}

# 실시간 복약 확인 체크 및 보호자 알림 트리거
def take_medication(elder_uid, schedule_id):
    """
    어르신이 복약 완료 체크 시 해당 일정 상태를 변경하고, 보호자 interaction 타임라인에 실시간 이벤트를 전송합니다.
    """
    try:
        sched_ref = db.collection("schedules").document(schedule_id)
        sched_data = sched_ref.get().get().to_dict() if hasattr(sched_ref.get(), 'to_dict') else sched_ref.get().to_dict()
        
        if not sched_data:
            return {"status": "fail", "message": "존재하지 않는 복약 일정입니다."}

        # 1. 복약 일정 도큐먼트 완료 상태 업데이트
        sched_ref.update({
            "is_taken": True,
            "taken_at": firestore.SERVER_TIMESTAMP
        })
        
        # 2. 노인 계정 조회를 통해 연결된 보호자 탐색
        elder_data = db.collection("users").document(elder_uid).get().to_dict()
        guardian_uid = elder_data.get("connected_with")
        
        # 3. 보호자가 존재할 경우 interaction 메타데이터에 실시간 로그 업데이트 (onSnapshot 감시용)
        if guardian_uid:
            nickname = elder_data.get("nickname", "어르신")
            med_name = sched_data.get("medicine_name", "약")
            
            db.collection("interaction").document(guardian_uid).set({
                "last_event": f"🔔 {nickname}님께서 [{med_name}] 복약을 성공적으로 완료하셨습니다.",
                "event_time": firestore.SERVER_TIMESTAMP,
                "type": "medication_confirmed"
            }, merge=True)
            return {"status": "success", "message": "복약 확인 및 보호자 실시간 알림 전송 완료"}
            
        return {"status": "success", "message": "복약 확인 완료 (연결된 보호자 없음)"}
        
    except Exception as e:
        return {"status": "error", "message": f"복약 체크 중 오류 발생: {str(e)}"}

# 보호자 원격 양방향 안심 메모 전송
def update_elder_memo(elder_uid, memo_text):
    """
    보호자가 남긴 응원 메시지나 주의 메모를 노인의 interaction 문서에 실시간 업데이트합니다.
    """
    try:
        db.collection("interaction").document(elder_uid).set({
            "guardian_memo": memo_text,
            "last_updated": firestore.SERVER_TIMESTAMP
        }, merge=True)
        return {"status": "success", "message": "어르신 화면으로 실시간 원격 안심 메모가 전송되었습니다."}
    except Exception as e:
        return {"status": "error", "message": f"메모 전송 중 오류 발생: {str(e)}"}
    
    #  3.이중 토큰(Access & Refresh) 발행 함수
def create_tokens(uid: str, role: str, nickname: str) -> dict:
    """Access Token 및 Refresh Token 이중 토큰 발행 알고리즘"""
    now = datetime.utcnow()
    
    # Access Token 페이로드 설계 (만료 30분)
    access_payload = {
        "sub": uid,
        "role": role,
        "nickname": nickname,
        "exp": now + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
        "type": "access"
    }
    access_token = jwt.encode(access_payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)
    
    # Refresh Token 페이로드 설계 (만료 2주)
    refresh_payload = {
        "sub": uid,
        "exp": now + timedelta(weeks=REFRESH_TOKEN_EXPIRE_WEEKS),
        "type": "refresh"
    }
    refresh_token = jwt.encode(refresh_payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)
    
    return {"access_token": access_token, "refresh_token": refresh_token}
