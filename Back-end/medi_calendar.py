import os
from datetime import datetime, timedelta
import pandas as pd
from firebase_admin import firestore

db = firestore.client()

# OCR 분석 결과를 기반으로 시간대별 복약 일정 일괄 생성 (Bulk Create)
def setup_medication_schedule(elder_uid, medicine_name, total_days, daily_times):
    base_date = datetime.now()
    
    for day in range(total_days):
        target_date = (base_date + timedelta(days=day)).strftime("%Y-%m-%d")
        for time in daily_times:
            db.collection("schedules").add({
                "elder_uid": elder_uid,
                "medicine_name": medicine_name,
                "date": target_date,
                "time": time,
                "is_taken": False  # 초기 복용 상태는 미복용(False)으로 강제 고정 
            })
    return "스케줄 생성 완료"


# DUR 공공데이터 캐싱 폴더 전수 병합 및 적재 프로세스
CSV_FOLDER_NAME = "건강보험심사평가원_의약품안전사용서비스(DUR) 의약품 목록"
CSV_FOLDER_PATH = os.path.join(os.path.dirname(__file__), CSV_FOLDER_NAME)

dur_df = None

try:
    if os.path.exists(CSV_FOLDER_PATH):
        all_files = os.listdir(CSV_FOLDER_PATH)
        data_files = [f for f in all_files if f.endswith('.csv') or f.endswith('.xlsx') or f.endswith('.xls')]
        
        df_list = []
        for file in data_files:
            file_full_path = os.path.join(CSV_FOLDER_PATH, file)
            
            if file.endswith('.csv'):
                # 변수 선언 버그 및 로드 최적화 완료
                temp_df = pd.read_csv(file_full_path, encoding="cp949", low_memory=False)
            else:
                temp_df = pd.read_excel(file_full_path)
                
            df_list.append(temp_df)
        
        if df_list:
            dur_df = pd.concat(df_list, ignore_index=True)
            print(f"✅ [성공] DUR 병용금기 공공데이터 통합 로드 완료! 총 {len(dur_df)}개의 의약품 인덱싱 완료.")
        else:
            print("⚠️ [경고] 해당 폴더 내에 읽어들일 수 있는 CSV/Excel 파일이 존재하지 않습니다.")
    else:
        print(f"❌ [에러] '{CSV_FOLDER_NAME}' 폴더를 식별할 수 없습니다. 경로 구조를 재배치하세요.")
        
except Exception as e:
    print(f"⚠️ [크래시] DUR 공공데이터 융합 가중치 로드 중 치명적 예외 발생: {e}")
    dur_df = None


# 데이터베이스 연동형 고속 병용금기 전수 검증 알고리즘 (Async 지원 전환)
async def check_drug_interaction(elder_uid: str, new_med_name: str) -> dict:
    """
    하이브리드 비동기 통신 규격으로 교정하여 main.py와 완벽하게 싱크를 맞춥니다.
    """
    if dur_df is None:
        return {"interact": False, "message": "DUR 시스템 점검 중입니다."}

    try:
        # 1. Firestore에서 해당 어르신의 실제 미복용 알약 리스트 쿼리
        schedules_ref = db.collection("schedules")
        docs = schedules_ref.where("elder_uid", "==", elder_uid).where("is_taken", "==", False).stream()
        
        current_med_list = set()
        for doc in docs:
            med_name = doc.to_dict().get("medicine_name")
            if med_name:
                current_med_list.add(med_name.strip())

        if not current_med_list:
            return {"interact": False, "message": "현재 복용 중인 약물이 없으므로 안전하게 등록 가능합니다."}

        # 2. Pandas Vectorization 연산을 통한 고속 양방향 성분 충돌 감지 매핑 
        for existing_med in current_med_list:
            match = dur_df[
                ((dur_df['제품명A'].str.contains(new_med_name, na=False)) & (dur_df['제품명B'].str.contains(existing_med, na=False))) |
                ((dur_df['제품명B'].str.contains(new_med_name, na=False)) & (dur_df['제품명A'].str.contains(existing_med, na=False)))
            ]

            if not match.empty:
                reason = match.iloc[0]['금기내용'] if '금기내용' in dur_df.columns else "병용 금기 의약품 위험군"
                return {
                    "interact": True,
                    "message": f"⚠️ 병용 오남용 위험 경고: 현재 복용 중이신 [{existing_med}]과 새로 등록하려는 [{new_med_name}]은 함께 복용 시 부작용 위험이 있습니다. (사유: {reason})"
                }

        return {"interact": False, "message": "안전한 의약품 조합입니다."}

    except Exception as e:
        return {"interact": False, "message": f"데이터 처리 중 일시적인 제약이 발생했습니다: {str(e)}"}