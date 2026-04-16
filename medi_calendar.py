from datetime import datetime, timedelta
from firebase_admin import firestore

db = firestore.client()

# [일정 생성] OCR 데이터를 기반으로 여러 날짜의 복약 일정 생성
def setup_medication_schedule(elder_uid, medicine_name, total_days, daily_times):
    # daily_times: ["08:00", "13:00", "19:00"] 등
    base_date = datetime.now()
    
    for day in range(total_days):
        target_date = (base_date + timedelta(days=day)).strftime("%Y-%m-%d")
        for time in daily_times:
            db.collection("schedules").add({
                "elder_uid": elder_uid,
                "medicine_name": medicine_name,
                "date": target_date,
                "time": time,
                "is_taken": False  # 초기값은 안 먹음
            })
    return "스케줄 생성 완료"