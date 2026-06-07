import hashlib
import uuid
from firebase_admin import firestore

db = firestore.client()

# [회원가입] 사용자 생성 및 고유 코드 발급
def create_user(email, role, nickname, password):
    try:
        user_ref = db.collection("users").document()
        uid = user_ref.id
        
        user_data = {
            "uid": uid,
            "email": email,
            "role": role,
            "nickname": nickname,
            "password": hash_password(password),  # 비밀번호 암호화
            "connected_with": None,
            "status": "unlinked"
        }
        
        if role == "elder":
            import random
            import string
            link_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            user_data["link_code"] = link_code
            
        user_ref.set(user_data)
        return user_data
    except Exception as e:
        return {"error": str(e)}

    
    #  비밀번호 암호문으로 바꾸는 함수
def hash_password(password: str):
    return hashlib.sha256(password.encode()).hexdigest()

# 로그인 검증 함수
def verify_user(email, password):
    # DB에서 해당 이메일을 가진 사용자 찾기
    users = db.collection("users").where("email", "==", email).stream()
    
    for user in users:
        data = user.to_dict()
        # 입력한 비밀번호를 암호화해서 DB에 저장된 암호문과 비교
        if data["password"] == hash_password(password):
            return {"status": "success", "message": "로그인 성공", "user": data}
            
    return {"status": "fail", "message": "이메일 또는 비밀번호가 틀렸습니다."}

# [연동] 보호자가 노인의 코드를 입력하여 연결 요청
def request_connection(guardian_uid, target_code):
    # 코드로 노인 찾기
    elder_query = db.collection("users").where("link_code", "==", target_code).stream()
    for doc in elder_query:
        elder_uid = doc.id
        # 연결 대기 상태로 저장 
        db.collection("connections").add({
            "elder_uid": elder_uid,
            "guardian_uid": guardian_uid,
            "status": "pending"
        })
        return "요청 완료"
    return "코드가 잘못되었습니다."


def update_elder_memo(elder_uid, memo_text):
    try:
        # elder_uid를 문서 ID로 사용하여 메모 업데이트
        db.collection("interaction").document(elder_uid).set({
            "guardian_memo": memo_text,
            "last_updated": firestore.SERVER_TIMESTAMP
        }, merge=True) # 기존 데이터가 있으면 합치고 없으면 새로 생성
        return {"status": "success", "message": "메모가 전송되었습니다."}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    

def approve_connection(elder_uid, connection_id):
    try:
        # 1. 연결 상태를 'linked'로 업데이트
        conn_ref = db.collection("connections").document(connection_id)
        conn_ref.update({"status": "linked"})
        
        # 2. 연결된 보호자의 ID 가져오기
        conn_data = conn_ref.get().to_dict()
        guardian_uid = conn_data.get("guardian_uid")
        
        # 3. 노인과 보호자 각자의 문서에 서로의 UID 저장 (매칭 완료)
        db.collection("users").document(elder_uid).update({"connected_with": guardian_uid})
        db.collection("users").document(guardian_uid).update({"connected_with": elder_uid})
        
        return {"status": "success", "message": "연결이 승인되었습니다!"}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    

def take_medication(elder_uid, schedule_id):
    try:
        # 1. 해당 일정의 상태를 '복용 완료'로 업데이트
        sched_ref = db.collection("schedules").document(schedule_id)
        sched_ref.update({
            "is_taken": True,
            "taken_at": firestore.SERVER_TIMESTAMP
        })

        # 2. 노인 정보를 조회하여 연결된 보호자가 있는지 확인
        elder_data = db.collection("users").document(elder_uid).get().to_dict()
        guardian_uid = elder_data.get("connected_with")

        if guardian_uid:
            # 3. 실시간 알림을 위해 interaction 컬렉션에 로그 기록
            # (프론트엔드에서 이 경로를 onSnapshot으로 감시하여 푸시 알림이나 팝업을 띄움)
            db.collection("interaction").document(guardian_uid).set({
                "last_event": f"{elder_data.get('nickname', '어르신')}님이 약을 복용하셨습니다.",
                "event_time": firestore.SERVER_TIMESTAMP,
                "type": "medication_confirmed"
            }, merge=True)
            
            return {"status": "success", "message": "복약 확인 및 보호자 알림 전송 완료"}
        
        return {"status": "success", "message": "복약 확인 완료 (연결된 보호자 없음)"}
    
    except Exception as e:
        return {"status": "error", "message": str(e)}
